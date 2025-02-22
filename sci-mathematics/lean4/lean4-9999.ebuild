
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
#EGIT_BRANCH="master"
#S="${WORKDIR}/lean4-${PV}/src"

LICENSE="Apache-2.0"
SLOT="0/${MAJOR}"

# Add cadical as dependence, due to cmake trouble on git-cloning it with proxy.
RDEPEND="dev-libs/gmp:= sci-mathematics/cadical"
DEPEND="${RDEPEND}"
BDEPEND=">=dev-build/cmake-3.11 llvm? ( sys-devel/llvm ) gmp? ( dev-libs/gmp ) ccache? ( dev-util/ccache ) threads? ( sys-libs/glibc )"
IUSE="debug +threads +githash +ccache llvm +gmp"

src_prepare() {
	filter-lto

	sed -e "s|-O[23]|${CFLAGS}|g" -i src/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local CMAKE_MAKEFILE_GENERATOR="emake"
	local CMAKE_BUILD_TYPE
	if use debug; then
		CMAKE_BUILD_TYPE="Debug"
	else
		CMAKE_BUILD_TYPE="Release"
	fi
	local mycmakeargs=(
		-DLEAN_EXTRA_MAKE_OPTS="-s 262144" # See: https://github.com/leanprover/lean4/issues/6434
		-DCMAKE_CXX_FLAGS:STRING="${CXXFLAGS}"
		-DCMAKE_INSTALL_PREFIX="/usr/local/"
		-DMULTI_THREAD=$(usex threads)
		-DUSE_GITHASH=$(usex githash)
		-DCCACHE=$(usex ccache)
		-DLLVM=$(usex llvm)
		-DUSE_GMP=$(usex gmp)
		-DINSTALL_CADICAL=OFF
		-DINSTALL_LICENSE=OFF
	)
	cmake_src_configure
}

src_compile() {
	ulimit -s 30000000
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
}
