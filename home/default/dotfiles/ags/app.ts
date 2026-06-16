import { App, Astal, Widget, Gtk, Gdk } from "astal/gtk3"
import { bind, Variable, readFile } from "astal"
import AstalMpris from "gi://AstalMpris"
import AstalNotifd from "gi://AstalNotifd"
import Pango from "gi://Pango"
import GLib from "gi://GLib"
import GdkPixbuf from "gi://GdkPixbuf"

const mpris = AstalMpris.Mpris.get_default()
const notifd = AstalNotifd.Notifd.get_default()

// ─── Notification popup item ──────────────────────────────────────────────────

// IDs of notifications currently shown in the popup, plus their auto-dismiss source ID
const popupIds = new Map<number, number>()

function removeFromPopup(id: number) {
    const src = popupIds.get(id)
    if (src) GLib.source_remove(src)
    popupIds.delete(id)
}

function NotifAvatar(n: any) {
    if (!n.image) return null
    try {
        const pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(n.image, 42, 42, false)
        const img = new Gtk.Image({ pixbuf, valign: Gtk.Align.CENTER })
        img.get_style_context().add_class("notif-avatar")
        return img
    } catch {
        return null
    }
}

function PopupItem(n: any, onHide: () => void) {
    const urgency = n.urgency === 2 ? "critical" : n.urgency === 0 ? "low" : "normal"
    const hasDefault = n.actions?.some((a: any) => a.id === "default")

    function activate() {
        if (hasDefault) n.invoke("default")
        onHide()
        if (!hasDefault) n.dismiss()
    }

    const avatar = NotifAvatar(n)

    return new Widget.Box({
        className: `notif-popup ${urgency}`,
        children: [
            ...(avatar ? [avatar] : []),
            new Widget.Button({
                className: "notif-popup-body-btn",
                hexpand: true,
                onClicked: activate,
                child: new Widget.Box({
                    vertical: true,
                    spacing: 4,
                    children: [
                        new Widget.Label({
                            className: "notif-popup-app",
                            label: n.appName || "",
                            xalign: 0,
                        }),
                        new Widget.Label({
                            className: "notif-popup-summary",
                            label: n.summary || "",
                            xalign: 0,
                            maxWidthChars: 30,
                            ellipsize: Pango.EllipsizeMode.END,
                        }),
                        ...(n.body ? [new Widget.Label({
                            className: "notif-popup-body",
                            label: n.body,
                            xalign: 0,
                            wrap: true,
                            maxWidthChars: 32,
                            useMarkup: false,
                        })] : []),
                    ],
                }),
            }),
            new Widget.Button({
                className: "notif-popup-close",
                valign: Gtk.Align.START,
                child: new Widget.Label({ label: "󰅖" }),
                onClicked: () => { onHide(); n.dismiss() },
            }),
        ],
    })
}

// Popup window: shows only newly-arrived notifications with an auto-dismiss timer.
// Does NOT show pre-existing notifications on startup.
function PopupWindow() {
    const box = new Widget.Box({ vertical: true, spacing: 8 })

    function rebuildPopup() {
        const dash = App.get_window("dashboard")
        const allNotifs = notifd.get_notifications()
        const popupNotifs = allNotifs.filter(n => popupIds.has(n.id))
        box.children = popupNotifs.map(n =>
            PopupItem(n, () => {
                removeFromPopup(n.id)
                rebuildPopup()
            })
        )
        const win = App.get_window("notifications-popup")
        if (win) win.visible = popupNotifs.length > 0 && !dash?.visible
    }

    notifd.connect("notified", (_: any, id: number) => {
        const n = notifd.get_notifications().find(x => x.id === id)
        if (!n) return

        // Cancel any existing timer for this ID (re-notify case)
        removeFromPopup(id)

        // Critical notifications stay until manually dismissed; others auto-hide
        if (n.urgency === 2) {
            popupIds.set(id, 0)
        } else {
            const timeoutMs = (n.expireTimeout > 0 ? n.expireTimeout : 5000)
            const src = GLib.timeout_add(GLib.PRIORITY_DEFAULT, timeoutMs, () => {
                removeFromPopup(id)
                rebuildPopup()
                return GLib.SOURCE_REMOVE
            })
            popupIds.set(id, src)
        }

        rebuildPopup()
    })

    notifd.connect("resolved", (_: any, id: number) => {
        removeFromPopup(id)
        rebuildPopup()
    })

    return new Widget.Window({
        name: "notifications-popup",
        namespace: "notifications-popup",
        anchor: Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT,
        layer: Astal.Layer.OVERLAY,
        marginTop: 50,
        marginRight: 10,
        visible: false,
        child: box,
    })
}

// ─── Dashboard ────────────────────────────────────────────────────────────────

function MediaPlayer() {
    const players = bind(mpris, "players")

    const title = new Widget.Label({
        className: "track-title",
        maxWidthChars: 26,
        ellipsize: Pango.EllipsizeMode.END,
        xalign: 0,
        label: players.as(p => p[0]?.title || "Nothing playing"),
    })

    const artist = new Widget.Label({
        className: "track-artist",
        maxWidthChars: 26,
        ellipsize: Pango.EllipsizeMode.END,
        xalign: 0,
        label: players.as(p => p[0]?.artist || ""),
    })

    const playIcon = new Widget.Label({
        label: players.as(p =>
            p[0]?.playbackStatus === AstalMpris.PlaybackStatus.PLAYING ? "󰏤" : "󰐊"
        ),
    })

    return new Widget.Box({
        className: "media-player",
        vertical: true,
        spacing: 10,
        children: [
            new Widget.Label({ className: "section-label", label: "󰝚  NOW PLAYING", xalign: 0 }),
            title,
            artist,
            new Widget.Box({
                className: "media-controls",
                halign: Gtk.Align.CENTER,
                spacing: 10,
                children: [
                    new Widget.Button({
                        className: "media-btn",
                        child: new Widget.Label({ label: "󰒮" }),
                        onClicked: () => mpris.get_players()[0]?.previous(),
                    }),
                    new Widget.Button({
                        className: "media-btn play-btn",
                        child: playIcon,
                        onClicked: () => mpris.get_players()[0]?.play_pause(),
                    }),
                    new Widget.Button({
                        className: "media-btn",
                        child: new Widget.Label({ label: "󰒭" }),
                        onClicked: () => mpris.get_players()[0]?.next(),
                    }),
                ],
            }),
        ],
    })
}

function CalendarWidget() {
    const cal = Variable("").poll(60000, "cal")
    return new Widget.Box({
        className: "calendar-widget",
        vertical: true,
        spacing: 8,
        children: [
            new Widget.Label({ className: "section-label", label: "󰃭  CALENDAR", xalign: 0 }),
            new Widget.Label({
                className: "calendar-body",
                label: bind(cal),
                useMarkup: false,
            }),
        ],
    })
}

function NotifItem(n: any) {
    const urgency = n.urgency === 2 ? "critical" : n.urgency === 0 ? "low" : "normal"
    const hasDefault = n.actions?.some((a: any) => a.id === "default")

    function activate() {
        if (hasDefault) n.invoke("default")
        n.dismiss()
        App.toggle_window("dashboard")
    }

    const avatar = NotifAvatar(n)

    return new Widget.Box({
        className: `notification-item ${urgency}`,
        children: [
            ...(avatar ? [avatar] : []),
            new Widget.Button({
                className: "notif-item-btn",
                hexpand: true,
                onClicked: activate,
                child: new Widget.Box({
                    vertical: true,
                    spacing: 4,
                    children: [
                        new Widget.Label({
                            className: "notif-summary",
                            label: n.summary || "",
                            xalign: 0,
                            ellipsize: Pango.EllipsizeMode.END,
                            maxWidthChars: 20,
                        }),
                        ...(n.body ? [new Widget.Label({
                            className: "notif-body",
                            label: n.body,
                            xalign: 0,
                            wrap: true,
                            maxWidthChars: 22,
                            useMarkup: false,
                        })] : []),
                    ],
                }),
            }),
            new Widget.Button({
                className: "notif-close-btn",
                valign: Gtk.Align.START,
                child: new Widget.Label({ label: "󰅖" }),
                onClicked: () => n.dismiss(),
            }),
        ],
    })
}

function NotifList() {
    const box = new Widget.Box({ vertical: true, spacing: 8, vexpand: true })

    function update() {
        const notifs = notifd.get_notifications()
        if (notifs.length === 0) {
            box.children = [new Widget.Label({
                className: "notif-empty",
                label: "All clear",
                vexpand: true,
                halign: Gtk.Align.CENTER,
                valign: Gtk.Align.CENTER,
            })]
        } else {
            box.children = [...notifs].reverse().map(NotifItem)
        }
    }

    notifd.connect("notified", update)
    notifd.connect("resolved", update)
    update()

    return box
}

let dashboardWin: Widget.Window
let popupWin: Widget.Window

function Dashboard() {
    return new Widget.Window({
        name: "dashboard",
        namespace: "dashboard",
        anchor: Astal.WindowAnchor.TOP,
        layer: Astal.Layer.OVERLAY,
        marginTop: 55,
        visible: false,
        keymode: Astal.Keymode.ON_DEMAND,
        onKeyPressEvent(self, event) {
            if (event.get_keyval()[1] === Gdk.KEY_Escape)
                App.toggle_window("dashboard")
        },
        child: new Widget.Box({
            className: "dashboard",
            spacing: 12,
            children: [
                // Left — notification list
                new Widget.Box({
                    className: "panel notif-panel",
                    vertical: true,
                    spacing: 10,
                    children: [
                        new Widget.Box({
                            children: [
                                new Widget.Label({
                                    className: "panel-title",
                                    label: "󰂚  Notifications",
                                    hexpand: true,
                                    xalign: 0,
                                }),
                                new Widget.Button({
                                    className: "clear-btn",
                                    child: new Widget.Label({ label: "clear" }),
                                    onClicked: () => {
                                        for (const n of notifd.get_notifications()) n.dismiss()
                                    },
                                }),
                            ],
                        }),
                        new Widget.Scrollable({
                            vexpand: true,
                            hscroll: Gtk.PolicyType.NEVER,
                            vscroll: Gtk.PolicyType.AUTOMATIC,
                            child: NotifList(),
                        }),
                    ],
                }),

                // Right — media + calendar
                new Widget.Box({
                    className: "panel right-panel",
                    vertical: true,
                    spacing: 14,
                    children: [
                        MediaPlayer(),
                        new Widget.Box({ className: "divider" }),
                        CalendarWidget(),
                    ],
                }),
            ],
        }),
    })
}

App.start({
    requestHandler(request: string, res: (response: any) => void) {
        const { type, name } = JSON.parse(request)
        if (type === "toggle_window") App.toggle_window(name)
        res("ok")
    },
    main() {
        App.apply_css(readFile(`${GLib.get_home_dir()}/.config/ags/style.css`), false)
        dashboardWin = Dashboard()
        popupWin = PopupWindow()
        App.add_window(dashboardWin)
        App.add_window(popupWin)
    },
})
