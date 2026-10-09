#!/bin/sh
# Wraps src/app.html into the installable index.html. Run after editing src/app.html.
cd "$(dirname "$0")"
{
  printf '<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n'
  printf '<link rel="manifest" href="manifest.webmanifest">\n<meta name="theme-color" content="#2356A3">\n<link rel="icon" href="icons/icon-192.png">\n<link rel="apple-touch-icon" href="icons/apple-touch-icon.png">\n'
  printf '<style>html{color-scheme:light}:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0}[hidden]{display:none!important}</style>\n</head>\n<body>\n'
  printf '<script src="vendor/supabase.js"></script>\n<script src="config.js"></script>\n<script src="https://accounts.google.com/gsi/client" async></script>\n'
  cat src/app.html
  printf '\n<script>if ("serviceWorker" in navigator && location.protocol !== "file:") navigator.serviceWorker.register("sw.js").catch(() => {});</script>\n</body>\n</html>\n'
} > index.html
