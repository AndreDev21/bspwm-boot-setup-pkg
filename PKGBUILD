# TODO: Altere a linha abaixo com seus dados
# Maintainer: Seu Nome <seu.email@exemplo.com>
pkgname='bspwm-boot-setup'
pkgver='1.0.0'
pkgrel=1
pkgdesc="A tool to configure and autostart applications on specific BSPWM workspaces."
arch=('any')
# TODO: Se tiver um repositório no GitHub/GitLab, coloque o link aqui
url="https://github.com/seu-usuario/seu-repositorio"
license=('MIT')
depends=('bspwm' 'yad' 'bash' 'libnotify')

# Os nomes aqui devem corresponder exatamente aos nomes dos arquivos na pasta
source=("${pkgname}-config.sh"
        "${pkgname}-autostart.sh"
        "${pkgname}.desktop")

# Deixe 'SKIP' por enquanto. O comando 'updpkgsums' irá preencher isso.
sha256sums=('e30c0e2cd7509d0142e74c328904a8cc96377eb19e9181b4c37d5a2a11977ec9'
            '5da46cd779267d2a0d0a20cd7cfb60397a7a5653d74b8180bf8427262c169ae0'
            '1d2cad9454e5a7883f7cd4c99e55f3ee17702bffa59145971b944609bacaec38')

package() {
  # Instala os scripts executáveis
  install -Dm755 "${srcdir}/${pkgname}-config.sh" "${pkgdir}/usr/bin/${pkgname}-config"
  install -Dm755 "${srcdir}/${pkgname}-autostart.sh" "${pkgdir}/usr/bin/${pkgname}-autostart"

  # Instala o arquivo .desktop para autostart
  install -Dm644 "${srcdir}/${pkgname}.desktop" "${pkgdir}/etc/xdg/autostart/${pkgname}.desktop"
}
