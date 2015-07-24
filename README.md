#pick_pic
[https://github.com/bokuo-okubo/PickPic](https://github.com/bokuo-okubo/PickPic)

A wrapper of curl script written in ruby multi thread.

## Requirement

- Ruby (>= 1.9)
- curl

## Usage

- Create a directory for got data.

ex.
```
$ mkdir save_directory
```

- Prepare url list as plain text in "data_source" directory.

like this.

```
$ echo 'http://hoge/201507241129178985291fa6a168208f9c5f653104d3fe.jpg' >> data_source/urls.txt
$ echo 'http://hoge/low_pages/20150724112918c2af7e415b1b9d7d88a864baf2ff1200.jpg' >> data_source/urls.txt
$ echo 'http://hoge/20150724112924d1d41aaf0ee5e1d471d591276bc704a6.jpg >> data_source/urls.txt

```

- Run pick_pic

forrow the std output, type your url-list's filename, and save-directory's name.



written by Yohei Okubo in Jul 24th 2015
