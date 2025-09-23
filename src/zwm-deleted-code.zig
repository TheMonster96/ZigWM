while(!mapped){
        if(xlib.XPending(display) > 0){
            std.debug.print("Cornuto dio porcaccio un evento\n", .{});
            _ = xlib.XNextEvent(display, &event);
            switch(event.type){
                xlib.MapNotify => {
                    std.debug.print("The window has been mapped\n", .{});
                    mapped=true;
                },
                else => {
                std.debug.print("Still waiting for MapNotify event\n", .{});
                },
            }
        }
        else{
            std.debug.print("Nessun dio porcaccio di evento\n", .{});
            break;
        }
    }

