console.log("Hi from the Service worker");
// serviceworker.js
// The serviceworker context can respond to 'push' events and trigger
// notifications on the registration property
self.addEventListener("push", (event) => {
  const json = JSON.parse(event.data.text());

  let title = json.title || "Yay a message";
  let body = json.body || "We have received a push message";
  let tag = "push-simple-demo-notification-tag";
  let icon = json.icon || "/android-chrome-192x192.png";
  let image = json.icon || "/android-chrome-192x192.png";
  let badge = json.icon || "/android-chrome-192x192.png";

  event.waitUntil(
    self.registration.showNotification(title, {
      body: body,
      icon: icon,
      tag: tag,
      image: image,
      badge: badge,
      vibrate: [200, 100, 200, 100, 200, 100, 200],
    })
  );
});
