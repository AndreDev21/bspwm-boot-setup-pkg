pkgname=boot-setup
pkgver=1.0.0
pkgrel=1
pkgdesc="Script interativo para abrir apps automaticamente em workspaces BSPWM"
arch=('any')
license=('MIT')
depends=('zenity' 'bspwm' 'xdotool' 'kitty' 'yay')
source=('boot-setup.sh' 'boot-setup.desktop')
sha256sums=(
    '79f89d14392faa3a5f1daf66b3239bddb54857ec1b397f809123bbda42003c30'  
    '371f9cbde1cd1f41c50d1d69f5358643a635cc4f4455c1dacbe310051d89db80'   # hash do .desktop
)
install=
package() {
  install -Dm755 "$srcdir/boot-setup.sh" "$pkgdir/usr/bin/boot-setup"
  install -Dm644 "$srcdir/boot-setup.desktop" "$pkgdir/usr/share/applications/boot-setup.desktop"
}