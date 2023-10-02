# Hello, tests!

To run tests, we will use:

- [ppx_inline_test](https://github.com/janestreet/ppx_inline_test) (easy)
- [ppx_assert](https://github.com/janestreet/ppx_assert) (harder but provides better error messages)

Although we *could* define "inline tests" inside our library code, we will separate them inside a `test` folder.

```
cd ./01-hello-tests
dune runtest --watch
```