# Release 1.3.1

- Address 'noSuggests' R CMD check failure
- Add article section to illustrate JSONPath.
- Fix bug in `j_pivot()`, as described in NEWS.md.
- The following NOTE is from the upstream cpp11 package so not under
  my direct control. Issues are open on the cpp11 GitHub repository.

    ```
    Check: compiled code
    Result: NOTE 
      File ‘rjsoncons/libs/rjsoncons.so’:
        Found non-API calls to R: ‘SETLENGTH’, ‘SET_GROWABLE_BIT’,
          ‘SET_TRUELENGTH’
    ```
