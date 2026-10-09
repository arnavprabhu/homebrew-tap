# Rendered by packaging/scripts/render-cask.sh. Do not edit the
# rendered file in the tap: the release workflow replaces it on every release.
cask "splashboard" do
  version "0.2.0"
  sha256 "3cad0f8c59f26e51dbb32358cbab0af38497c66efad63cb10e69a7d6034d71ab"

  url "https://github.com/arnavprabhu/splashboard/releases/download/v#{version}/Splashboard-#{version}.dmg"
  name "Splashboard"
  desc "Menu bar app and web admin for the Splash local inference engine"
  homepage "https://github.com/arnavprabhu/splashboard"

  auto_updates true
  depends_on arch: :arm64
  depends_on formula: "incoai/tap/splash"
  depends_on macos: :tahoe

  app "Splashboard.app"

  # Ad hoc signed, not notarized, so macOS blocks the first open.
  caveats <<~EOS
    Splashboard is not notarized, so macOS blocks its first open. Open System Settings,
    then Privacy & Security, and click Open Anyway next to "Splashboard".
  EOS

  uninstall launchctl:  "io.github.arnavprabhu.splashboard.manager",
            quit:       "io.github.arnavprabhu.splashboard",
            login_item: "Splashboard"

  # Zap keeps ~/.splash/models and ~/.splash/cache (large, user-downloaded) and removes the app's own state.
  # The Splash engine and its formula are never touched. MCP secrets (named by a digest) are removed by
  # `splash doctor --uninstall`, which can read the settings that name them.
  zap script: {
        executable: "/bin/sh",
        args:       [
          "-c",
          "for s in \"$@\"; do /usr/bin/security delete-generic-password -s \"$s\" >/dev/null 2>&1; done; true",
          "zap",
          "io.github.arnavprabhu.splashboard.apikey", "io.github.arnavprabhu.splashboard.hf", "io.github.arnavprabhu.splashboard.session", "io.github.arnavprabhu.splashboard.codexrouter"
        ],
      },
      trash:  [
        "~/.splash/bin",
        "~/.splash/chats",
        "~/.splash/downloads.json",
        "~/.splash/integrations",
        "~/.splash/logs",
        "~/.splash/run",
        "~/.splash/settings.json",
        "~/.splash/usage.db",
        "~/.splash/usage.db-shm",
        "~/.splash/usage.db-wal",
        "~/Library/Preferences/io.github.arnavprabhu.splashboard.plist",
      ]
end
