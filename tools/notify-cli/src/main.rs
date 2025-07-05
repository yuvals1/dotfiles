use notify_rust::Notification;
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    
    let (title, message) = match args.len() {
        1 => ("Notification", "Hello from CLI!"),
        2 => ("Notification", args[1].as_str()),
        _ => (args[1].as_str(), args[2].as_str()),
    };
    
    // Just fire and forget the notification
    let _ = Notification::new()
        .summary(title)
        .body(message)
        .show();
}