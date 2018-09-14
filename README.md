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

The database structure (using crow's foot notation) of the database holding the repositories to analyze and the results is depicted in the figure below. All tables have two fields "inserted_at" and "updated_at", which contain a time stamp indicating when a record was created or updated.

![Database structure][figure2]

The table "todos" contains all repositories that have to be analyzed. The field
"url" contains the URL pointing to the repository. The fields "started" and
"completed" describe if a machine began and/or finished to analyze a repository;
these fields are useful for debugging, i.e., to understand how far a given
machine has come, at which repository it stopped, etc. The field
"assigned_to_machine" is used to assign a group of repositories to a specific
machine. The field "study" is useful to group repositories into different
studies. The results are aggregated into studies. 

The table "repositories" contains all results regarding one repository. The
field "single_license_file_exists" describes if the repository contains a single
license file, the field "spdx_license_file_exists" if the repository contains a
bill of materials file according to the SPDX specification, The field
"license_folder_exists" describes if a "LICENSES" folder exists containing
several licenses, the field "all_used_licenses_are_present" describes if all
licenses referenced by source code files are found in the "LICENSES" folder or
in the single license file. The field "debian_license_folder_exists" describes
if a license file according to the "machine-readable debian/copyright" was
found. The field "readme_exists" describes if a README file was found, and
finally the field "authors_file_exists" describes if an "AUTHORS",
"CONTRIBUTORS", or "MAINTAINERS" file was found.

The table "licenses" contains all SPDX identifiers referenced by source code
files stored in the field "license". This table is useful to determine whether
all licenses referenced by files are also later found in a single license file
or in the LICENSES folder.

The table "files" contains all results regarding one file. The field "url"
contains the url to the file. The fields "started" and "completed" describe if a
machine began and/or finished to analyze a file; these fields are useful for
debugging, i.e., to understand how far a given machine has come, at which
repository it stopped, etc. The field "has_copyright" describes whether the word
"copyright" was found in the file, the field "license_found_in_file" describes
whether the word "license" was found in the file. The field
"spdx_license_expression" describes whether a SPDX license expression was found
in the file, the field "spdx_license_expression_is_valid" if the expression is
valid, i.e., if it refers to licenses and exceptions that are part of the
official 348 licenses and 32 possible exceptions defined by SPDX. The field
"license_found_in_dot_license" describes whether a ".license" file was found,
the field "license_found_in_debian_format" describes whether the file was
mentioned within a "machine-readable debian/copyright" file, and the field
"license_found_in_dot_spdx" describes whether the file was mentioned within a
bill of materials file according to the SPDX specification. Finally, the field
"license_header_in_case_of_error" is a field we used for debugging purposes,
which contains the first 4096 bytes of a file in case of an error.

** How to use install and use reuse-checker
To install and use reuse-checker, you need to perform the following steps:

*  Download and install the Phoenix Framework from <https://phoenixframework.org/>.
*  Download and install PostgreSQL from <https://www.postgresql.org/>
*  Download the source code from  <https://github.com/riccardofelluga/reuse-checker>
*  If you want to run the version to check a single repository:
   * Start Reuse-Checker running **mix phx.server** within the root project directory.
   * Open <http://localhost:4000>.
   * You can enter the repository to check and you will see the results after it
     has been downloaded and evaluated.
*  If you want to run the version to study many repositories: 
   * Prepare a list of GitHub repositories to evaluate and store it in the table
     "todos" (setting the url of each repositories in the field "url", setting
     "started" and "completed" to false, assigning a machine id to the
     repository in "assigned_to_machine" (see above), assigning a study number,
     e.g., 1.
   *  Start Reuse-Checker running **mix phx.server** within the root project directory.
   *  Open <http://localhost:4000/study>. This will display the web site shown
      in figure \ref{fig:checker-screen-shot}, which allows the user to start
      the analysis, stop it, reset it completely, or to reset only repositories
      not completely analyzed yet. These options where written to ease the
      analysis of a large number of repositories, which is often
      interrupted/fails because of various reasons, e.g., no more available
      space on the hard disk, a lost Internet connection, etc.
   *  After a study is completed, one can see the results calling
      \url{http://localhost:4000/results?study=1}, assuming that the study id is
      1 as in the example above.

** Source code documentation




[figure1]: https://github.com/riccardofelluga/reuse-checker/blob/master/documentation/idea.png "Overall idea of reuse-checker"
[figure2]: https://github.com/riccardofelluga/reuse-checker/blob/master/documentation/database.png "Database structure"