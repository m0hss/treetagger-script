# sara_perl_project

<https://cental.uclouvain.be/treetagger/>
<https://www.ims.uni-stuttgart.de/en/research/resources/tools/treetagger/>
<https://www.linguisticsweb.org/doku.php?id=linguisticsweb:tutorials:automaticannotation:treetagger>

## Notes

* I used Lignua TreeTagger Installer to install on my mac

## Install

```sh
wget https://cpan.metacpan.org/authors/id/A/AX/AXANTHOS/Lingua-TreeTagger-0.10.tar.gz
http://www.cpan.org/authors/id/A/AM/AMBS/Lingua-TreeTagger-Installer-0.54.tar.gz
https://www.youtube.com/watch?v=YAGH8fXKdfw
https://cadottorato.github.io/sito/treetagger-windows.html
```

```sh
perl Build.PL
perl Build 
perl Build test 
perl build install
```

```sh
tree-tagger-install-lang -i FR-2
ls /Users/macos/perl5/lib/perl5/Lingua/
```

## Links

```txt
https://www.cis.lmu.de/~schmid/tools/TreeTagger/
```

Dictionary used:

```xml
https://www.cnrtl.fr/dictionnaires/expressions_idiomatiques/dico/fp.xml
```

Needs to have Perl installed and cpan configured:

```sh
perl --version
sudo cpan install LWP::Protocol::https
```

## Run

```sh
perl src/read_file.pl
perl src/cnrtl.pl
```

```sh
sudo cpan Lingua::TreeTagger
/Users/macos/Desktop/works/perl/sara_perl_project/lib/tree-tagger-MacOSX-Intel-3.2.3 2/bin/tree-tagger
```

##  Server

```sh
morbo server.pl
https://raw.githubusercontent.com/yuki-kimoto/winmorbo/master/winmorbo.bat
```

##

End of the book

```txt
END OF THE PROJECT GUTENBERG EBOOK
```

### Windows Issue

perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
        LC_ALL = (unset),
        (possibly more locale environment variables)
        LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the system default locale ("French_France.1252").

##

```sh
cd /c/Users/bensa/Documents/METHODO LFIAL2630/sara_perl_project/src
```
