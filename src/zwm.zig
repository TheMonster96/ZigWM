const std=@import("std");
const xlib=@cImport({
    @cInclude("X11/Xlib.h");
});



pub fn main() !void {

    const display: ?*xlib.struct__XDisplay = xlib.XOpenDisplay(null) orelse null;
    
    while(true){}

    defer _=xlib.XCloseDisplay(display);
}
