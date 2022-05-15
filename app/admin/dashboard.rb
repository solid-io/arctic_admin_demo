# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }
  # <%# https://medium.com/seed-digital/using-vapid-for-web-push-notifications-in-a-ruby-on-rails-application-e8e3ae00ab50 %>
  # <%# https://github.com/rossta/serviceworker-rails %>
  # <%# https://github.com/zaru/webpush/issues/64 %>
  # <%# https://github.com/zaru/webpush/blob/master/lib/webpush/errors.rb %>
  # <%# https://github.com/zaru/webpush/blob/master/lib/webpush/request.rb#L29 %>

  # content title: proc { I18n.t("active_admin.dashboard") } do
  # div class: "blank_slate_container", id: "dashboard_default_message" do
  #   span class: "blank_slate" do
  #     span I18n.t("active_admin.dashboard_welcome.welcome")
  #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
  #   end
  # end
  # end # content

  # REPORTS = %w[AdminUsers Companies Locations Schedules]

  content do
    panel "Welcome back, #{current_admin_user.email}!" do
        para "Welcome to..."

        text_node link_to("Enable Push", "#", { id: "utility-navigation-enable-push", class: "button", onclick: "myFunction(#{Base64.urlsafe_decode64(Rails.application.credentials.webpush[:public_key]).bytes}, #{current_admin_user.id})" })

        script do
          raw <<~JS
          function myFunction(publicKey, admin_user_id) {

            let permission = Notification.permission;
            let client = {}

            function requestPermission() {
              if (permission === 'denied') {
                // alert('Permission for Notifications was denied');
                console.log('Permission for Notifications was denied');
              } else if (permission === 'default') {
                Notification.requestPermission(function (permission) {
                  if (permission === 'granted') {
                    clientDetails()
                    registerServiceworker()
                    // alert('Permission for Notifications was granted');
                    console.log('Permission for Notifications was granted');
                  } else {
                    // alert('Permission for Notifications was denied');
                    console.log('Permission for Notifications was denied');
                  }
                });
              }
            }

            function clientDetails() {
              // CLIENT DETAILS
              var objappVersion = navigator.appVersion;
              var browserAgent = navigator.userAgent;
              var browserName = navigator.appName;
              var browserVersion = '' + parseFloat(navigator.appVersion);
              var browserMajorVersion = parseInt(navigator.appVersion, 10);
              var Offset, OffsetVersion, ix;
              var osName = "Unknown OS";

              // For Chrome
              if ((OffsetVersion = browserAgent.indexOf("Chrome")) != -1) {
                  browserName = "Chrome";
                  browserVersion = browserAgent.substring(OffsetVersion + 7);
              }

              // For Microsoft internet explorer
              else if ((OffsetVersion = browserAgent.indexOf("MSIE")) != -1) {
                  browserName = "Microsoft Internet Explorer";
                  browserVersion = browserAgent.substring(OffsetVersion + 5);
              }

              // For Firefox
              else if ((OffsetVersion = browserAgent.indexOf("Firefox")) != -1) {
                  browserName = "Firefox";
              }

              // For Safari
              else if ((OffsetVersion = browserAgent.indexOf("Safari")) != -1) {
                  browserName = "Safari";
                  browserVersion = browserAgent.substring(OffsetVersion + 7);
                  if ((OffsetVersion = browserAgent.indexOf("Version")) != -1)
                      browserVersion = browserAgent.substring(OffsetVersion + 8);
              }

              // For other browser "name/version" is at the end of userAgent
              else if ((Offset = browserAgent.lastIndexOf(' ') + 1) <
                  (OffsetVersion = browserAgent.lastIndexOf('/'))) {
                  browserName = browserAgent.substring(Offset, OffsetVersion);
                  browserVersion = browserAgent.substring(OffsetVersion + 1);
                  if (browserName.toLowerCase() == browserName.toUpperCase()) {
                      browserName = navigator.appName;
                  }
              }

              // Trimming the fullVersion string at
              // semicolon/space if present
              if ((ix = browserVersion.indexOf(";")) != -1)
                  browserVersion = browserVersion.substring(0, ix);
              if ((ix = browserVersion.indexOf(" ")) != -1)
                  browserVersion = browserVersion.substring(0, ix);

              browserMajorVersion = parseInt('' + browserVersion, 10);
              if (isNaN(browserMajorVersion)) {
                  browserVersion = '' + parseFloat(navigator.appVersion);
                  browserMajorVersion = parseInt(navigator.appVersion, 10);
              }

              if (navigator.userAgent.indexOf("Win") != -1) osName =
                "Windows OS";
              if (navigator.userAgent.indexOf("Mac") != -1) osName =
                "Macintosh";
              if (navigator.userAgent.indexOf("Linux") != -1) osName =
                "Linux OS";
              if (navigator.userAgent.indexOf("Android") != -1) osName =
                "Android OS";
              if (navigator.userAgent.indexOf("like Mac") != -1) osName =
                "iOS";

              // document.write(''
              //     + 'Name of Browser = ' + browserName + '<br>'
              //     + 'Full version = ' + browserVersion + '<br>'
              //     + 'Major version = ' + browserMajorVersion + '<br>'
              //     + 'navigator.appName = ' + navigator.appName + '<br>'
              //     + 'navigator.userAgent = ' + navigator.userAgent + '<br>'
              //     + 'OS = ' + osName + '<br>'
              // );

              client = {
                "browserName": browserName,
                "browserVersion": browserVersion,
                "browserMajorVersion": browserMajorVersion,
                "objappVersion": objappVersion,
                "browserAgent": browserAgent,
                "osName": osName,
                "admin_user_id": admin_user_id
              };
            }

            function registerServiceworker() {
              const vapidPublicKey = new Uint8Array(publicKey);
              if (navigator.serviceWorker) {
                navigator.serviceWorker.register("/serviceworker.js").then(function (reg) {
                  // console.log("Service worker change, registered the service worker");
                  navigator.serviceWorker.ready.then((serviceWorkerRegistration) => {
                    serviceWorkerRegistration.pushManager
                    .subscribe({
                      userVisibleOnly: true,
                      applicationServerKey: vapidPublicKey
                    }).then(async function (subscription) {
                      // console.log("Subscribed to push notifications");
                      // console.log({subscription});
                      const webpush_subscriptions = {
                        "subscription": subscription,
                        "client": client
                      };

                      const data = await fetch("/webpush_subscriptions", {
                        method: "POST",
                        headers: {
                          "Content-Type": "application/json"
                        },
                        body: JSON.stringify({webpush_subscriptions})
                      }).then(res => res.json());
                      // console.log(data);
                    });
                  });
                });
              }
              // Otherwise, no push notifications :(
              else {
                console.error("Service worker is not supported in this browser");
              }
            }

            requestPermission();
          }
          JS
        end
      end


    # columns do
    #   column  do
    #     panel "Reports" do
    #       table do
    #         REPORTS.each do |report|
    #           tr do
    #             td do
    #               link_to("#{report}", "/admin/#{report.tableize}")
    #             end
    #           end
    #         end
    #       end
    #     end
    #   end
    #   column span: 2 do
    #     # span "Column # 2"
    #     panel "Recent Companies" do
    #       ul do
    #         Company.all.map do |company|
    #           li link_to(company.name, admin_company_path(company))
    #         end
    #       end
    #     end
    #   end
    # end
  end
end
