---
title: Homepage
layout: null
---

# {{ page.title }}

{% assign my_img = 'assets/satelliet.jpg' %}

See also [Subpath][] test page.

[Subpath]: {% link subpath.md %}


## Resized

Liquid:

```
{{ my_img | resize: "200x200>" }}
```

Rendered image:

![Test image]({{ my_img | resize: "200x200>" }})

## formatted

Liquid:

```
{{ my_img | format: "webp" }}
```

Rendered image:

![Test image]({{ my_img | resize: "200x200>" }})

Liquid:

```
resize: "200x200^,webp,80,1:1+0+0,East"
```

Rendered image:

![Test image]({{ my_img | resize: "200x300^,webp,80,2:3+0+0,East" }})

## cropped

Liquid:

```
{{ my_img | format: "webp" }}
```

Rendered image:

![Test image]({{ my_img | resize: "200x200>" | crop: "100x100+0+0,Center" }})

## reduce quality

Liquid:

```

{{ my_img | format: "webp" }}
```

Rendered image:

![Test image]({{ my_img | resize: "200x200>" | quality: "10" }})

## Through cli!

Liquid:

```
imageMagick: "-resize 100x100 -negate"
```

Rendered image:

![Test image]({{ my_img | imageMagick: "-resize 100x100 -negate" }})

## Original

Liquid:

```
{{ my_img}}
```

Rendered image:

![Test image]({{ my_img }})
