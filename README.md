# Ads Blocking WKWebView for iOS 11

This is a sample app so you can use this project's code as you want.

iOS 11 introduces Content Filter on WWDC 2017 [Customized Loading in WKWebView](https://developer.apple.com/videos/play/wwdc2017/220/)

> A common case we hear from developers is they're working on a browser targeted for schools, libraries, some other public place where the content loaded in the browser has to be family friendly. So we need to filter out everything is not family friendly. In a similar vane, we've heard from developers working on corporate intranet applications that they have varying needs within the same app.
>
> One WebView might need to block all content that is not coming from the corporate's network.
>
> Another WebView might need to block all content coming from certain specific servers.
>
> You can have each WebView setup to do its own thing on a per sub resource basis.

## Steps

1. Prepare json format rule lists (literal strings or files).
2. Compile them in runtime code with each identifier.
3. Register each of them with the identifer.

> When you provide your rule list to WebKit, WebKit compiles into an efficient byte code format. This is kind of an implementation detail that's not directly relevant to you. I'm bringing it up because I want to assure you that a content rule list even a large set of thousands of rules we've been spending a lot of time working on making that as efficient as possible. And no matter how big your rule set is, if it compiles successfully you should not see degradation in loading performance. You supply your rules in a simple JSON format.
>
>
> When we compile a rule list from JSON to the efficient byte code format, you can name it.
> 
> And then later you can look up by the same identifier so you don't have to compile it again.
> 
> WebKit stores it on the storage of the device and can look it up much quicker later.


WKWebView's Content-Blocking Rules is the same as Safari's.
[Creating Safari Content-Blocking Rules](https://developer.apple.com/library/content/documentation/Extensions/Conceptual/ContentBlockingRules/CreatingRules/CreatingRules.html)


## Ads Block Hosts
This sample app borrows host list from [Adaway](https://github.com/AdAway/AdAway/wiki/HostsSources).

And conviert host file to json format by using this command line:

`curl -ls 'https://adaway.org/hosts.txt' | grep -E '^[0-9]' | grep -v -E '\slocalhost\s*$' | perl -pe 's/^[0-9.]+\s(.+)\s*$/{"trigger":{"url-filter":"$1"},"action":{"type":"block"}},/mg' | perl -pe 's/\A(.+),\z/[$1]/g' > adaway.json`



## PR

* [Ohajiki Web Browser for iOS](http://en.ohajiki.ios-web.com/)
* [Ohajiki Web Browser for Android](https://play.google.com/store/apps/details?id=co.fukuyama.android.ohajiki)
