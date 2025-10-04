const std=@import("std");
const xlib=@cImport({
    @cInclude("X11/Xutil.h");
    @cInclude("X11/Xlib.h");
});



var clients: [10]xlib.Window= undefined;
var wm_detected: bool= false;

pub fn ConfigureWindow(confreq_event: *xlib.XConfigureRequestEvent, display: ?*xlib.struct__XDisplay) void{
    var wchanges: xlib.XWindowChanges= .{};
    wchanges.x = confreq_event.x;
    wchanges.y = confreq_event.y;
    wchanges.width = confreq_event.width;
    wchanges.height = confreq_event.height;
    wchanges.border_width = confreq_event.border_width;
    wchanges.sibling = confreq_event.above;
    wchanges.stack_mode = confreq_event.detail;

    _ = xlib.XConfigureWindow(display, confreq_event.window, @intCast(confreq_event.value_mask), @ptrCast(@constCast(&confreq_event)));
}

pub fn OnMapRequest(map_request: *xlib.XMapRequestEvent, display: *xlib.struct__XDisplay, root_window: *xlib.Window) void {
    Frame(&map_request.window, root_window, display);   
    
    _ = xlib.XMapWindow(display, map_request.window);
}

pub fn Frame(window: *xlib.Window,  root_window: *xlib.Window, display: *xlib.struct__XDisplay) void {
    const BORDER_WIDTH: u4= 3;
    const BORDER_COLOR: u24= 0xff0000;
    const BG_COLOR: u24= 0x0000FF;
    
    var x_window_attr: xlib.XWindowAttributes= .{};
    _ = xlib.XGetWindowAttributes(display, window.*, &x_window_attr);

    const frame: xlib.Window = xlib.XCreateSimpleWindow(
            display,
            root_window.*,
            @intCast(x_window_attr.x),
            x_window_attr.y,
            @intCast(x_window_attr.width),
            @intCast(x_window_attr.height),
            BORDER_WIDTH,
            BORDER_COLOR,
            BG_COLOR
        );

    _ = xlib.XSelectInput(display, root_window.*, xlib.SubstructureRedirectMask | xlib.SubstructureNotifyMask);

    _ = xlib.XAddToSaveSet(display, window.*);

    _ = xlib.XReparentWindow(display, window.*, frame, 0, 0);

    _ = xlib.XMapWindow(display, frame);

    clients[window.*] = frame;

    _ = xlib.XGrabKey(
            display, 
            xlib.XKeysymToKeycode(display, xlib.XStringToKeysym("F2")),
            xlib.Mod1Mask,
            root_window.*,
            1,
            xlib.GrabModeAsync,
            xlib.GrabModeAsync
        );

    std.debug.print("Framed a new window\n", .{});

}


pub fn CreateSimpleClientWindow(window: *xlib.Window) !void {
    _ = window;
    return error.ToBeImplemented;
}

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
    
    //TODO: Understand why this builtin doesn't work in this case
    //std.debug.print("{any}", .{@typeInfo(xlib.union__XEvent)});
    

//     var class_hint: xlib.XClassHint= .{
//      .res_name=@as([*c]u8, @constCast(@ptrCast("Zig WM".ptr))),
//      .res_class=@as([*c]u8, @constCast(@ptrCast("ZWM".ptr))),
//  };

    //TODO: Add a struct to encapsulate all the Display/Window core functions to have a more reusable code and to remove unnecessary complexity
    const display: ?*xlib.struct__XDisplay = xlib.XOpenDisplay(null) orelse null;
    defer _ = xlib.XCloseDisplay(display);
    
    _ = xlib.XSetErrorHandler(OnWMDetected);

    if(display == null){
        std.debug.print("Display failed to open", .{});
        std.os.linux.exit(1);    
    }

    const root_window: xlib.Window= xlib.XDefaultRootWindow(@constCast(@ptrCast(display.?)));

 // const colormap: xlib.Colormap= xlib.DefaultColormap(display, 0);
 // var xcolor: xlib.XColor= undefined;

 // _ = xlib.XParseColor(display, colormap, "#181818", @as([*c]xlib.XColor, @ptrCast(&xcolor)));
 // _ = xlib.XAllocColor(display, colormap, @as([*c]xlib.XColor, @ptrCast(&xcolor)));
 // 

 // const screen= xlib.XDefaultScreen(display);
 // const root_window= xlib.XRootWindow(display, screen);
 // //const white_pixel= xlib.XWhitePixel(display, screen);

 // const window: xlib.Window= xlib.XCreateSimpleWindow(
 //         display,
 //         root_window,
 //         0, 0,
 //         800, 600,
 //         1,
 //         xlib.XBlackPixel(display, screen),
 //         xcolor.pixel,
 //     );

 // defer _= xlib.XDestroyWindow(display, window);


 // _ = xlib.XMapWindow(display, window);
 // _ = xlib.XFlush(display);


  var event: xlib.union__XEvent= std.mem.zeroes(xlib.union__XEvent);

 // 
 // _ = xlib.XSetClassHint(display, window, &class_hint);
 // _ = xlib.XStoreName(display, window, "Zig WM window".ptr);

 // _ = xlib.XSync(display, 0);
 // _ = xlib.XFlush(display);
 // //_ = xlib.XSetInputFocus(display, window, xlib.RevertToNone, xlib.CurrentTime);

 // _ = xlib.XSync(display, 0);
 // _ = xlib.XFlush(display);
    _ = xlib.XSelectInput(display, root_window, xlib.SubstructureRedirectMask | xlib.SubstructureNotifyMask);

    _ = xlib.XSetErrorHandler(OnXError);
    
        while(true){
        _ = xlib.XNextEvent(display, &event);
        std.debug.print("Event type: {d}\n", .{event.type});
        switch(event.type){
            xlib.Expose => {},
            xlib.KeyPress => {
                std.debug.print("Key pressed\n", .{});
                
            },
            xlib.CreateNotify => {
                std.debug.print("Notified for window creation\n", .{});
            },
            xlib.DestroyNotify => {
                std.debug.print("Notified for window destruction\n", .{});
            },
            xlib.ReparentNotify => {
                std.debug.print("Notified for window reparenting\n", .{});
            },
            xlib.ConfigureRequest => {
            ConfigureWindow(&event.xconfigurerequest, display.?);
            },
            xlib.MapRequest => {
                OnMapRequest(&event.xmaprequest, display.?, @constCast(&root_window));
            },
            else => {}
        }
    }
    

   }
