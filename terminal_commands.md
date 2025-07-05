```bash
# taking pages 41-44 from pdf
qpdf --pages material/07-codegen.pdf 41-44 -- material/07-codegen.pdf output.pdf
# merging pdfs
qpdf --empty --pages q1.pdf q2.pdf -- sol4.pdf
# converting markdown to pdf
pandoc homework4.md -o homework4.pdf
```

```bash
aerospace reload-config && sketchybar --reload
```
