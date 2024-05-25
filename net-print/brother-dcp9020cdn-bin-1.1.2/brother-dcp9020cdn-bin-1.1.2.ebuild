# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm linux-info

DESCRIPTION="Brother printer driver for DCP-9020CDN"

HOMEPAGE="http://support.brother.com"

SRC_URI="https://download.brother.com/welcome/dlf102670/dcp9020cdnlpr-1.1.2-1.i386.rpm
https://download.brother.com/welcome/dlf102671/dcp9020cdncupswrapper-1.1.4-0.i386.rpm"

LICENSE="brother-eula GPL-2"

SLOT="0"

KEYWORDS="amd64 x86"

RESTRICT="mirror strip"

DEPEND="net-print/cups"
RDEPEND="${DEPEND}"

S=${WORKDIR}

pkg_setup() {
	CONFIG_CHECK=""
	if use amd64; then
		CONFIG_CHECK="${CONFIG_CHECK} ~IA32_EMULATION"
	fi

	linux-info_pkg_setup
}

src_unpack() {
	rpm_unpack ${A}
}

src_install() {
	mkdir -p "${D}"/usr/libexec/cups/filter || die
	mkdir -p "${D}"/usr/share/cups/model/Brother || die
	cp -r opt "${D}" || die
	cp -r usr "${D}" || die

	sed -n 110,260p "${D}"/opt/brother/Printers/dcp9020cdn/cupswrapper/cupswrapperdcp9020cdn | sed 's/${printer_model}/dcp9020cdn/g;s/${device_model}/Printers/g;s/${printer_name}/DCP9020CDN/g;s/\\//g' > "${D}"/usr/libexec/cups/filter/brother_lpdwrapper_dcp9020cdn || die
	chmod 0755 "${D}"/usr/libexec/cups/filter/brother_lpdwrapper_dcp9020cdn || die

	( ln -s "${D}"/opt/brother/Printers/dcp9020cdn/cupswrapper/brother_dcp9020cdn_printer_en.ppd "${D}"/usr/share/cups/model/Brother/brother_dcp9020cdn_printer_en.ppd ) || die
}

pkg_postinst() {
	einfo "Brother DCP-9020CDN printer installed"
}
