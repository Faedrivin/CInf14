%%%%%%%%%%%%%%%%%%%%%%%
%
% CInf Template class 
%
%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%
% Document class
%%%%%%%%%%%%%%%%%%%%%%%

\LoadClass[11pt,a4paper,oneside]{article}

%%%%%%%%%%%%%%%%%%%%%%%
% Packages
%%%%%%%%%%%%%%%%%%%%%%%
% To provide more registers to load more packages
% since we were at the limit for \dimen
% (see: http://www.tex.ac.uk/cgi-bin/texfaq2html?label=noroom)
\RequirePackage{etex}

% layout etc.
\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}
\RequirePackage[top=2cm, bottom=2.5cm, left=2.5cm, right=2cm]{geometry}
\RequirePackage{lmodern, listings, environ}

% math
\RequirePackage{amsmath, amsthm, amssymb, array, IEEEtrantools}

% tables
\RequirePackage{ltablex}\keepXColumns % restores tabularx' X column behaviour
\RequirePackage{multicol, multirow, colortbl, booktabs}

% lists/enumerations
\RequirePackage{enumitem}

% graphics, diagrams
\RequirePackage{graphicx, tikz, calc}
\RequirePackage[european]{circuitikz}

% other packages
\RequirePackage[
  %pdfdisplaydoctitle = true, % TODO: enable by default, disable in draft mode
  hyperfootnotes     = true,
  colorlinks,
  bookmarksnumbered  = true,
  linkcolor          = lightgray,
  plainpages         = false,
  citecolor          = lightgray
  ]{hyperref}

\RequirePackage{xstring, ifthen}

% not used yet
% subcaption, microtype, textcomp 
 
%%%%%%%%%%%%%%%%%%%%%%%
% Configuration
%%%%%%%%%%%%%%%%%%%%%%%

\author{Rasmus Diederichsen, Sebastian H\"offner}

% Have listings print the line number such that they accord with the parameters
% firstline or linerange given to an individual listing. See
% http://tex.stackexchange.com/questions/110187/listings-line-numbers-that-match-the-linerange-specification
\lst@Key{matchrangestart}{f}{\lstKV@SetIf{#1}\lst@ifmatchrangestart}
\def\lst@SkipToFirst{%
    \lst@ifmatchrangestart\c@lstnumber=\numexpr-1+\lst@firstline\fi
    \ifnum \lst@lineno<\lst@firstline
        \def\lst@next{\lst@BeginDropInput\lst@Pmode
        \lst@Let{13}\lst@MSkipToFirst
        \lst@Let{10}\lst@MSkipToFirst}%
        \expandafter\lst@next
    \else
        \expandafter\lst@BOLGobble
    \fi}

\lstset{
   tabsize=2,
   basicstyle   = \footnotesize\ttfamily,
   breaklines   = true,
   commentstyle = \color{blue},
   keywordstyle = \color{purple}\textbf,
   numberstyle  = \tiny\color{gray},
   numbers      = left,
   title        = \lstname,
   stringstyle  = \color{olive},
   matchrangestart=t,
   linewidth=\textwidth,
   xleftmargin=\marginparwidth,
}
\lstdefinelanguage{RTeasy}{keywords={fi,declare,register,array,bus,memory,goto,then,read}}

% generate document meta data
\AtBeginDocument{
  \hypersetup{
    pdftitle    = {Informatik C -- \"Ubung \@sheet\ -- \@title},
    pdfauthor   = {\@author},
    pdfsubject  = {\@title},
    pdfcreator  = {LaTeX},
  }
}

% choose tikz libraries
\usetikzlibrary{shapes, automata, positioning, arrows, calc, intersections, matrix}
\tikzstyle{highlight}=[densely dotted,line width=.8pt,draw,rounded corners=5pt]
\tikzstyle{matrix node}=[anchor=center,draw,shape=rectangle,text width=3em,minimum height=3em,text centered]


\tikzstyle{typewriter} = [font=\small\ttfamily]
% define styles for program flow charts
\tikzstyle{decision} = [diamond, draw, fill=blue!20, typewriter,
                        text width=4.5em, text badly centered, inner sep=0pt]
\tikzstyle{block}    = [rectangle, draw, fill=blue!10, typewriter,
                        text width=7em, text centered, minimum height=2em]
\tikzstyle{line}     = [draw, -latex', typewriter]
\tikzstyle{cloud}    = [draw, ellipse,fill=red!20, node distance=3cm,
                        minimum height=1em, typewriter]
\tikzstyle{subprogram}    = [rectangle, draw, typewriter,
                        text width=7em, text centered, minimum height=2em,append after command={
   \pgfextra{
      \draw ($(\tikzlastnode.north west) + (5pt,0)$) 
         -- ($(\tikzlastnode.south west) + (5pt,0)$);
      \draw ($(\tikzlastnode.north east) - (5pt,0)$) 
         -- ($(\tikzlastnode.south east) - (5pt,0)$);
      }
   }
]

% styles for circuit diagrams
\newlength{\portsize}
\setlength{\portsize}{\widthof{\&}*3}
\tikzstyle{and port}=[font={\&},draw,shape=rectangle,text centered,text
   width=\portsize,minimum height=1.3*\portsize] % :D why the fuck do I need to scale the length for minimum height to get a friggin square?
\tikzstyle{or port}=[font={$\ge 1$},draw,shape=rectangle,text centered,text
   width=\portsize,minimum height=1.3*\portsize] 
   \tikzstyle{inverter}=[font=\tiny{1},minimum height=.3cm,
   text width=.3cm,rectangle,anchor=center,
   align=center,
   inner sep=0,
draw ]
\tikzstyle{and gate}=[rectangle,font=\small,align=center,draw,fill=white,inner
sep=1pt,minimum height=.7em]

\usetikzlibrary{intersections}
%%%%%%%%%%%%%%%%%%%%%%%
% Definitions
%%%%%%%%%%%%%%%%%%%%%%%

% sheet number
\def\sheet#1#2{\def\@sheet{#1}\title{#2}} % \sheet{<Number>}{<Title>}

% (sub)exercise counter
\newcounter{excount}
\newcounter{subexcount}[excount]

% typewriter left/center/right
\newcolumntype{L}{>{\ttfamily}l}
\newcolumntype{C}{>{\ttfamily}c}
\newcolumntype{R}{>{\ttfamily}r}

% bold left
\newcolumntype{B}{>{\bf}l}

% mathcolumn
\newcolumntype{m}{>{$}c<{$}}

% helper for headers/individual rows
% define columns with a special row type with extra columns e.g.
% e.g. Hchchc for three centered columns
\newcolumntype{H}{>{\global\let\currentrowstyle\relax}}
\newcolumntype{h}{>{\currentrowstyle}}
\newcommand{\rowstyle}[1]{\gdef\currentrowstyle{#1} % \rowstyle{<style>}
  #1\ignorespaces
}

% table emphasis
\newcommand{\temph}{\cellcolor{blue!10}} % \temph{<text>}


%%%%%%%%%%%%%%%%%%%%%%%
% Other Macros
%%%%%%%%%%%%%%%%%%%%%%%

% Generates and prints the title
\newcommand{\cinftitle}{ % \cinftitle
  \begin{center}
    \textbf{\Large Informatik C} \\
    Grundlagen der Technischen Informatik \\
    \@author \\
    \textbf{Tutor:} Ralph Buß\\[.5\baselineskip]
    
    \textbf{ \LARGE{\"Ubung \@sheet} \large{-- \@title} }
    
    \smallskip
    
    \hrule
  \end{center}
}

% Prints an exercise's headline
\newcommand{\ex}[3][]{ % \ex[<Number>]{<Title>}{<Points>}
  \ifx&#1&
    \stepcounter{excount}
  \else
    \setcounter{excount}{#1}
  \fi
  \ifnum \value{excount}>1
    \par\bigskip
  \fi
  \noindent\begin{tabularx}{\textwidth}{l>{\centering}Xr}
     \bf Aufgabe \@sheet.\arabic{excount}: & \bf #2 & \bf(#3 =
     \pgfmathparse{int(#3)}\pgfmathresult{} P)
  \end{tabularx}
  %\vspace{\baselineskip}
  \par
}

% prints an additional exercise's headline
\newcommand{\addex}[2][]{ % \addex[<Number>]{<Title>}
  \ifx&#1&
    \stepcounter{excount}
  \else
    \setcounter{excount}{#1}
  \fi
  \ifnum \value{excount}>1
    \par\bigskip
  \fi
  \noindent\begin{tabularx}{.9\textwidth}{l>{\centering}Xr}
    \bf Zusatzaufgabe \@sheet.\arabic{excount} & \bf #2 & \bf (freiwillig)
  \end{tabularx}
  \vspace{\baselineskip}
  \par
}

% Prints a subexercise's number
\newcommand{\subex}[2][-1]{ % \subex[<Number>]{<Title>}
  \ifnum#1=-1
    \stepcounter{subexcount}
  \else
    \setcounter{subexcount}{#1}
  \fi
  \par\vspace{\baselineskip}
  {\setlength{\parindent}{1cm} \bf \alph{subexcount})\ifx&#2&\else{ #2}\fi}
  \par\vspace{\baselineskip}
}

% assemblertablehead
\newcommand{\assemblertablehead}{
  \hline
  \rmfamily\multirow{2}{1cm}{Adr (hex)} 
    & \multicolumn{2}{c|}{\rmfamily M(Adr) (hex)} 
    & \rmfamily\multirow{2}{*}{Label} 
    & \rmfamily\multirow{2}{*}{Opcode} 
    & \rmfamily\multirow{2}{*}{Operand} 
    & \multicolumn{1}{c|}{\rmfamily\multirow{2}{*}{Kommentare}} \\
  & \footnotesize\rmfamily Opc. 
    & \rmfamily\footnotesize Oper. & & & & \\ \hline\hline
}

% environment for a table with assembler code (not functioning with page breaks)
\NewEnviron{assemblertable}{%
  \small
  \noindent\begin{tabularx}{\textwidth}{|L||L|L|L||L|R|X|} 
    \assemblertablehead
    \BODY
    \hline
  \end{tabularx}
}


% short hand for $\leftarrow$
\newcommand{\la}{\ensuremath{\leftarrow{}}}

% complement for boolean algebra
\newcommand{\comp}[1]{% \comp{<expr>}
\noexpandarg\StrLen{#1}[\strlen]
\ensuremath
\ifnum\strlen=1
\bar{\vphantom{b}#1}
\else
\overline{\vphantom{b}#1}
\fi
}

%% Centered Tabular. I *always* end up manually centering these. Who would want
%% an uncentered tabular?
\newenvironment{ctabular}[1]{
   \begin{center}
      \begin{tabular}{#1}
      }
      {
      \end{tabular}
   \end{center}
}
