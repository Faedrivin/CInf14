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

% layout etc.
\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}
\RequirePackage[top=2cm, bottom=2.5cm, left=2.5cm, right=2cm]{geometry}
\RequirePackage{lmodern, listings, multirow, tabularx}

% math
\RequirePackage{amsmath, amssymb, array, IEEEtrantools}

% tables
\RequirePackage{tabularx, multicol, colortbl, booktabs}

% graphics, diagrams
\RequirePackage{graphicx, tikz}

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

\RequirePackage{enumitem}

% not used yet
% subcaption, microtype, textcomp 
 
%%%%%%%%%%%%%%%%%%%%%%%
% Configuration
%%%%%%%%%%%%%%%%%%%%%%%

\author{Rasmus Diederichsen, Sebastian H\"offner}

\lstset{
  xleftmargin  = .2\textwidth, 
  xrightmargin = .2\textwidth,
  basicstyle   = \footnotesize\ttfamily,
  language     = Python,
  breaklines   = true,
  commentstyle = \color{blue},
  keywordstyle = \color{purple}\textbf,
  numberstyle  = \tiny\color{gray},
  numbers      = left,
  stringstyle  = \color{olive},
}

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
%\usetikzlibrary{automata, arrows}

%%%%%%%%%%%%%%%%%%%%%%%
% Definitions
%%%%%%%%%%%%%%%%%%%%%%%

% sheet number
\def\sheet#1#2{\def\@sheet{#1}\title{#2}} % \sheet{Number}{Title}

% (sub)exercise counter
\newcounter{excount}
\newcounter{subexcount}[excount]

% typewriter left/center/right
\newcolumntype{L}{>{\ttfamily}l}
\newcolumntype{C}{>{\ttfamily}c}
\newcolumntype{R}{>{\ttfamily}r}

% bold left
\newcolumntype{B}{>{\bf}l}

% helper for headers/individual rows
\newcolumntype{H}{>{\global\let\currentrowstyle\relax}}
\newcolumntype{h}{>{\currentrowstyle}}
\newcommand{\rowstyle}[1]{\gdef\currentrowstyle{#1}% \rowstyle{style}
  #1\ignorespaces
}

% table emphasis
\newcommand{\temph}{\cellcolor{blue!10}}


%%%%%%%%%%%%%%%%%%%%%%%
% Other Macros
%%%%%%%%%%%%%%%%%%%%%%%

% Generates and prints the title
\newcommand{\cinftitle}{ % \cinftitle
  \begin{center}
    \textbf{\Large Informatik C} \\
    Grundlagen der Technischen Informatik \\
    \@author \\
    \textbf{Tutor:} Konstantin Obermann\\[.5\baselineskip]
    
    \textbf{ \LARGE{\"Ubung \@sheet} \large{-- \@title} }
    
    \smallskip
    
    \hrule
  \end{center}
}

% Prints an exercise's headline
\newcommand{\ex}[3][]{ % \ex[Number]{Title}{Points}
  \ifx&#1&
    \stepcounter{excount}
  \else
    \setcounter{excount}{#1}
  \fi
  \ifnum \value{excount}>1
    \par\bigskip
  \fi
  \noindent\begin{tabularx}{.9\textwidth}{l>{\centering}Xr}
    \bf Aufgabe \@sheet.\arabic{excount} & \bf #2 & \bf(#3 P)
  \end{tabularx}

  \vspace{\baselineskip}
  \par
}

% prints an additional exercise's headline
\newcommand{\addex}[2][]{ % \addex[Number]{Title}
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
\newcommand{\subex}[2][]{ % \subex[Number]{Title}
  \ifx&#1&
    \stepcounter{subexcount}
  \else
    \setcounter{subexcount}{#1}
  \fi
  \par%\smallskip
  {\setlength{\parindent}{1cm} \bf \alph{subexcount})\ifx&#2&{ }#2\fi}
  \vspace{\baselineskip}
}

% environment for a table with assembler code
\newenvironment{assemblertable}{%
  \noindent\tabularx{\textwidth}{|L||L|L|L||L|R|X|} 
    \hline
    \rmfamily\multirow{2}{1cm}{Adr (hex)} 
        & \multicolumn{2}{c|}{\rmfamily M(Adr) (hex)} 
        & \rmfamily\multirow{2}{*}{Label} 
        & \rmfamily\multirow{2}{*}{Opcode} 
        & \rmfamily\multirow{2}{*}{Operand} 
        & \multicolumn{1}{c|}{\rmfamily\multirow{2}{*}{Kommentare}} \\
    & \footnotesize\rmfamily Opc. 
        & \rmfamily\footnotesize Oper. & & & & \\ \hline\hline
}{\endtabularx}
