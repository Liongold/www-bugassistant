#
#     Copyright (C) 2011 Loic Dachary <loic@dachary.org>
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http:www.gnu.org/licenses/>.
#

all: build

build: build-en build-fr

check: check-en

clean: clean-en

build-en: extract-en compose-en

extract-en:
	mkdir -p build_en
	curl --silent https://wiki.documentfoundation.org/BugReport_Details | tidy --numeric-entities yes -asxhtml 2>/dev/null > build_en/tidyout.xhtml || echo "ignoring tidy error"
	xsltproc --encoding UTF-8 --novalid stripnamespace.xsl build_en/tidyout.xhtml > build_en/BugReport_Details.xhtml
	xsltproc --encoding UTF-8 --novalid component_comments.xsl build_en/BugReport_Details.xhtml > build_en/component_comments.xhtml
	xsltproc --stringparam choose "`cat en/choose.txt`" --stringparam other "(All other problems)" --encoding UTF-8 --novalid subcomponents.xsl build_en/BugReport_Details.xhtml > build_en/subcomponents.xhtml
	xsltproc --encoding UTF-8 --novalid subcomponents.xsl build_en/BugReport_Details.xhtml > build_en/subcomponents.xhtml
	xsltproc --encoding UTF-8 --novalid components.xsl build_en/BugReport_Details.xhtml > build_en/components.xhtml
	curl --silent 'https://bugs.freedesktop.org/query.cgi?product=LibreOffice&query_format=advanced' > build_en/query.xhtml
	perl op_sys.pl "`cat en/choose.txt`" < en/op_sys.txt > build_en/op_sys.xhtml
	perl query.pl < build_en/query.xhtml > build_en/versions.xhtml
	perl sanity.pl build_en/query.xhtml build_en/components.xhtml

compose-en:
	xsltproc --encoding UTF-8 --novalid --stringparam serial `date +%s` bug.xsl bug.xhtml > bug/bug.html

check-en:
	perl sanity.pl TEST

clean-en:
	rm -f build_en/BugReport_Details.xhtml build_en/tidyout.xhtml build_en/component_comments.xhtml build_en/subcomponents.xhtml build_en/components.xhtml build_en/query.xhtml build_en/versions.xhtml bug/bug.html
	rmdir build_en

build-fr: extract-fr compose-fr 

extract-fr:
	mkdir -p build_fr
	curl --silent https://wiki.documentfoundation.org/fr/BugReport_Details | tidy --numeric-entities yes -asxhtml 2>/dev/null > build_fr/tidyout.xhtml || echo "ignoring tidy error"
	xsltproc --encoding UTF-8 --novalid stripnamespace.xsl build_fr/tidyout.xhtml > build_fr/BugReport_Details.xhtml
	xsltproc --encoding UTF-8 --novalid component_comments.xsl build_fr/BugReport_Details.xhtml > build_fr/component_comments.xhtml
	xsltproc --stringparam choose "`cat fr/choose.txt`" --stringparam other "(All other problems)" --encoding UTF-8 --novalid subcomponents.xsl build_en/BugReport_Details.xhtml > build_en/subcomponents.xhtml
	xsltproc --encoding UTF-8 --novalid components.xsl build_fr/BugReport_Details.xhtml > build_fr/components.xhtml
	curl --silent 'https://bugs.freedesktop.org/query.cgi?product=LibreOffice&query_format=advanced' > build_fr/query.xhtml
	perl op_sys.pl "`cat fr/choose.txt`" < fr/op_sys.txt > build_fr/op_sys.xhtml
	perl query.pl < build_fr/query.xhtml > build_fr/versions.xhtml
	perl sanity.pl build_fr/query.xhtml build_fr/components.xhtml

compose-fr:
	xsltproc --encoding UTF-8 --novalid --stringparam serial `date +%s` bug.xsl bug.xhtml > bug/bug.html

clean-fr:
	rm -f build_fr/BugReport_Details.xhtml build_fr/tidyout.xhtml build_fr/component_comments.xhtml build_fr/subcomponents.xhtml build_fr/components.xhtml build_fr/query.xhtml build_fr/versions.xhtml bug/bug_fr.html
	rmdir build_fr
