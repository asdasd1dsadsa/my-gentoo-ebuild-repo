
# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MAJOR=$(ver_cut 1)

inherit cmake readme.gentoo-r1

DESCRIPTION="Lean 4 programming language and theorem prover"
HOMEPAGE="https://leanprover.github.io/"

inherit git-r3
EGIT_REPO_URI="https://github.com/leanprover/lean4.git"
EGIT_CLONE_TYPE=shallow
#S="${WORKDIR}/lean4-${PV}/src"

LICENSE="Apache-2.0"
SLOT="0/${MAJOR}"

RDEPEND="dev-libs/gmp:="
DEPEND="${RDEPEND}"
BDEPEND=">=dev-util/cmake-3.11"
IUSE="debug"

src_configure() {
	local CMAKE_MAKEFILE_GENERATOR="emake"
	local CMAKE_BUILD_TYPE
	if use debug; then
		CMAKE_BUILD_TYPE="Debug"
	else
		CMAKE_BUILD_TYPE="Release"
	fi
	local mycmakeargs=(
		-DCMAKE_CXX_FLAGS:STRING="${CXXFLAGS}"
		-DCMAKE_INSTALL_PREFIX="/usr/local/lean4"
	)
	cmake_src_configure
}

src_compile() {
	rm "${S}/LICENSE"
	rm "${S}/LICENSES"
	local CMAKE_MAKEFILE_GENERATOR="emake"
	cmake_build
}

src_test() {
	local CMAKE_MAKEFILE_GENERATOR="emake"
	local myctestargs=(
		# Disable problematic "style_check" cpplint test,
		# this also removes the python test dependency
		--exclude-regex style_check
	)
	cmake_src_test
}

src_install() {
	local CMAKE_MAKEFILE_GENERATOR="emake"
	cmake_src_install
	#local DOC_CONTENTS="File 'LICENSE' and 'LICENSES' will also be installed and installed to the root directory of CMAKE_INSTALL_PREFIX. We need a patch for future, for now you may want to manually delete them."
	loccal DOC_CONTENTS="Install to '/usr/local/lean/'"
	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
