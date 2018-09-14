# Reuse-checker

Reuse-checker is a web application to verify if a Git repository follows the
best practices defined by the [REUSE guidelines](https://reuse.software/).

Reuse-checker can be used in two ways: to analyze one repository or to analyze
many repositories. The default version is the one to analyze one repository and
is deployed on <https://smart.inf.unibz.it/reuse>.

To analyze many repositories, the overall idea of reuse-checker is depicted in
the figure below: several machines can be used to analyze the repositories, each
machine has an assigned id. 

![Overall idea][figure1]

A PostgreSQL database that needs to be installed together with the
reuse-checker, contains all repositories to analyze and the machine that is
assigned to each repository. This means that one could assign 500 repositories
to one machine, 500 to another, and so on. Each machine performs the following
steps:

* The URL of the next repository, assigned to the machine and that has not yet
  been analyzed is obtained from the database (step 1).
* The repository is cloned locally using the command line switch \texttt{--depth
  1} to omit downloading all commits of the past (steps 2 and 3).
* The repository is analyzed and the results are written to the central database (step 4).

While the repositories are analyzed, the current status is visualized as depicted in Figure \ref{fig:checker-screen-shot}. One sees the number of repositories initially assigned to the machine, the overall progress, the repositories that still have to be processed, the time the analysis started and stopped, and the repositories currently analyzed.

[figure1]: https://github.com/riccardofelluga/reuse-checker/blob/master/documentation/idea.png "Overall idea of reuse-checker"