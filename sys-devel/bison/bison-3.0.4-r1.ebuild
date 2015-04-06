# Distributed under the terms of the GNU General Public License v2

EAPI=5

WANT_AUTOMAKE="1.14"

inherit flag-o-matic eutils autotools

DESCRIPTION="A general-purpose (yacc-compatible) parser generator"
HOMEPAGE="http://www.gnu.org/software/bison/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~*"
IUSE="examples nls static test"

RDEPEND=">=sys-devel/m4-1.4.16"
DEPEND="${RDEPEND}
	sys-devel/flex
	examples? ( dev-lang/perl )
	nls? ( sys-devel/gettext )
	test? ( dev-lang/perl )"

DOCS=( AUTHORS ChangeLog-2012 NEWS README THANKS TODO ) # ChangeLog-1998 PACKAGING README-alpha README-release

src_prepare() {
	epatch "${FILESDIR}"/${P}-optional-perl.patch #538300
	eautoreconf
}

src_configure() {
	use static && append-ldflags -static

ac_cv_path_PERL=true \
	econf \
		--docdir='$(datarootdir)'/doc/${PF} \
		$(use_enable examples) \
		$(use_enable nls)
}

src_install() {
	default

	# This one is installed by dev-util/yacc
	mv "${ED}"/usr/bin/yacc{,.bison} || die
	mv "${ED}"/usr/share/man/man1/yacc{,.bison}.1 || die

	# We do not need liby.a
	rm -r "${ED}"/usr/lib* || die

	# Move to documentation directory and leave compressing for EAPI>=4
	mv "${ED}"/usr/share/${PN}/README "${ED}"/usr/share/doc/${PF}/README.data
}

pkg_postinst() {
	local f="${EROOT}/usr/bin/yacc"
	if [[ ! -e ${f} ]] ; then
		ln -s yacc.bison "${f}"
	fi
}

pkg_postrm() {
	# clean up the dead symlink when we get unmerged #377469
	local f="${EROOT}/usr/bin/yacc"
	if [[ -L ${f} && ! -e ${f} ]] ; then
		rm -f "${f}"
	fi
}