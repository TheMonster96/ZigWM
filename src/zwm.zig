const std=@import("std");
const xlib=@cImport({
    @cInclude("X11/Xutil.h");
    @cInclude("X11/Xlib.h");
});


var wm_detected: bool= false;

//TODO: Add a struct or union to encapsulate XErrors so that it's clearer which error occurred and give more detailed information

pub fn OnWMDetected(dpy: ?*xlib.struct__XDisplay, err: [*c]xlib.XErrorEvent) callconv(.c) c_int{
    _ = dpy;
    if(err.*.error_code == xlib.BadAccess){
         wm_detected=true;
    }
    
    return 0;
}

pub fn OnXError(dpy: ?*xlib.struct__XDisplay, err: [*c]xlib.XErrorEvent) callconv(.c) c_int{
    _ = dpy;
    std.debug.print("Error raised:  {any}\n", .{err.*});

    return 0;
}


pub fn main() !void {

    var class_hint: xlib.XClassHint= .{
        .res_name=@as([*c]u8, @constCast(@ptrCast("Zig WM".ptr))),
        .res_class=@as([*c]u8, @constCast(@ptrCast("ZWM".ptr))),
    };

    //TODO: Add a struct to encapsulate all the Display/Window core functions to have a more reusable code and to decrease complexity
    const display: ?*xlib.struct__XDisplay = xlib.XOpenDisplay(null) orelse null;
    defer _=xlib.XCloseDisplay(display);
    
    _ = xlib.XSetErrorHandler(OnWMDetected);

    std.debug.print("ciao\n", .{});
    if(display == null){
        std.debug.print("Display failed to open", .{});
        std.os.linux.exit(1);    
    }

    const colormap: xlib.Colormap= xlib.DefaultColormap(display, 0);
    var xcolor: xlib.XColor= undefined;

    _ = xlib.XParseColor(display, colormap, "#181818", @as([*c]xlib.XColor, @ptrCast(&xcolor)));
    _ = xlib.XAllocColor(display, colormap, @as([*c]xlib.XColor, @ptrCast(&xcolor)));
    

    const screen= xlib.XDefaultScreen(display);
    const root_window= xlib.XRootWindow(display, screen);
    //const white_pixel= xlib.XWhitePixel(display, screen);

    const window= xlib.XCreateSimpleWindow(
            display,
            root_window,
            0, 0,
            800, 600,
            1,
            xlib.XBlackPixel(display, screen),
            xcolor.pixel,
        );

    defer _= xlib.XDestroyWindow(display, window);


    _ = xlib.XMapWindow(display, window);
    _ = xlib.XFlush(display);


    var event: xlib.union__XEvent= std.mem.zeroes(xlib.union__XEvent);

    
    _ = xlib.XSetClassHint(display, window, &class_hint);
    _ = xlib.XStoreName(display, window, "Zig WM window".ptr);

    _ = xlib.XSync(display, 0);
    _ = xlib.XFlush(display);
    _ = xlib.XSetInputFocus(display, window, xlib.RevertToParent, xlib.CurrentTime);

    _ = xlib.XSync(display, 0);
    _ = xlib.XFlush(display);
    _ = xlib.XSelectInput(display, window, xlib.KeyPressMask | xlib.ExposureMask);

    _ = xlib.XSetErrorHandler(OnXError);
    
        while(true){
        _ = xlib.XNextEvent(display, &event);
        std.debug.print("Event type: {d}\n", .{event.type});
        switch(event.type){
            xlib.Expose => {},
            xlib.KeyPress => {
                std.debug.print("Key pressed\n", .{});
                
            },
            else => {}
        }
    }
    

   }
