% CInf Template class
\ProvidesClass{CInf_practice}

\LoadClass[11pt,a4paper,oneside]{article}

\RequirePackage{microtype, textcomp, multicol, colortbl, booktabs, listings, tikz, IEEEtrantools, array, amsmath, amssymb, graphicx, subcaption, lmodern}
\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}

\RequirePackage[top=2.5cm, bottom=2.5cm, left=2cm, right=2cm]{geometry}

\RequirePackage{tabularx}

\RequirePackage{listings}
\lstset{
  xleftmargin=.2\textwidth, xrightmargin=.2\textwidth,
   basicstyle=\footnotesize\ttfamily,
   language=Python,
   breaklines=true,
   commentstyle=\color{blue},
   keywordstyle=\color{purple}\textbf,
   numberstyle=\tiny\color{gray},
   numbers=left,
   stringstyle=\color{olive},
}

\def\sheet#1{\def\@sheet{#1}}
\RequirePackage[pdftitle={Informatik C -- \"Ubung }, % TODO: How to reference sheet variable here?
   pdfauthor={Rasmus Diederichsen and Sebastian H\"offner}, 
   hyperfootnotes=true,
   colorlinks,
   bookmarksnumbered = true,
   linkcolor = lightgray,
   plainpages = false,
citecolor = lightgray]{hyperref}

\newcommand{\cinftitle}{ % \cinftitle
  \begin{center}
    \textbf{\Large Informatik C}\\
    Grundlagen der Technischen Informatik\\
    Rasmus Diederichsen, Sebastian H\"offner\\
    \textbf{Tutor:} Markus Rothl\"ubbers\\[\baselineskip]
    
    \textbf{ \LARGE{\"Ubung \@sheet} \large{-- \@title} }
  \end{center}
}

% exercise counter
\newcounter{excount}

% subexercise counter
\newcounter{subexcount}[excount]

\newcommand{\ex}[3][]{
  \ifx&#1&
    \stepcounter{excount}
  \else
    \setcounter{excount}{#1}
  \fi
  \ifnum \value{excount}>1
    \par\bigskip
  \fi
  \begin{tabularx}{.9\textwidth}{l>{\centering}Xr}
    \textbf{Aufgabe \@sheet.\arabic{excount}} & \textbf{#2} & \textbf{(#3 P)}
  \end{tabularx}
  \par
}

\newcommand{\subex}[1][]{
  \ifx&#1&
    \stepcounter{subexcount}
  \else
    \setcounter{subexcount}{#1}
  \fi
  \par\smallskip
  {\setlength{\parindent}{1.5cm}\textbf{\alph{subexcount})}\ }
}
