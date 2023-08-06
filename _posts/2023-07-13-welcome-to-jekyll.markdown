---
layout: post
title:  "Welcome to Jekyll!"
date:   2023-07-13 13:22:52 -0400
category: [Random, Random]
layout: search

# nextPart: _posts/2021-01-30-example.md #Next part.
# prevPart: _posts/2021-01-30-example.md #Previous part.
og_image: /assets/img/me.jpg #Open Graph preview image.
og_description: "Example description." #Open Graph description.
fb_app_id: example

# classes: wide
# show_date: true
# layout: splash
# layout: single

toc: true
# toc_sticky: true
# last_modified_at: 2023-06-26T00:00:00-04:00

---
You’ll find this post in your `_posts` directory. Go ahead and edit it and re-build the site to see your changes. You can rebuild the site in many different ways, but the most common way is to run `jekyll serve`, which launches a web server and auto-regenerates your site when a file is updated.

Jekyll requires blog post files to be named according to the following format:

`YEAR-MONTH-DAY-title.MARKUP`

Where `YEAR` is a four-digit number, `MONTH` and `DAY` are both two-digit numbers, and `MARKUP` is the file extension representing the format used in the file. After that, include the necessary front matter. Take a look at the source for this post to get an idea about how it works.


```html
<a href="/assets/img/me.jpg" data-lity>
  <img src="/assets/img/me.jpg"/>
</a>
```

To provide image description use this syntax:

<div class="sx-picture">
  <a href="/assets/img/me.jpg" data-lity>
    <img src="/assets/img/me.jpg"/>
  </a>
  <span class="title">My picture description.</span>
</div>

To center pictures, put the code inside a `div` with `sx-center` class like this:
```html
<div markdown=1 class="sx-center">
  ![My picture](/assets/example.jpg)
</div>
```


<div class='sx-button'>
  <a href='https://your.link.here.example.com/' class='sx-button__content theme'>
    <img src='/assets/img/icons/example_icon.svg'/>#{text}
  </a>
</div>

The source of the generic demo is available here: https://github.com/andreondra/simplex-demo


Jekyll also offers powerful support for code snippets:

{% highlight ruby %}
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
{% endhighlight %}

Check out the [Jekyll docs][jekyll-docs] for more info on how to get the most out of Jekyll. File all bugs/feature requests at [Jekyll’s GitHub repo][jekyll-gh]. If you have questions, you can ask them on [Jekyll Talk][jekyll-talk].

[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/


