#!/usr/bin/env python3
import sys
import os
#import socks
#import socket
import urllib.request
from bs4 import BeautifulSoup

syzbot = "https://syzkaller.appspot.com"

kernel_map = {
    'upstream': 'linux',
    'net':'net',
    'net-next':'net-next',
    'linux-next':'linux-next-history',
    'bpf':'bpf',
    'bpf-next':'bpf-next',
    "https://github.com/google/kmsan.git master":"kmsan",
    "https://github.com/google/ktsan.git kcsan":"ktsan",
    "https://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb.git usb-testing":"usb"
}

close_kernel = [
    "mmots"
]

def write_conf(kernel, fix_commit, k_id, syz_id, config_url, log_url, report_url,
                syz_url, poc_url, ID):
    template = '''#! /bin/bash

bug_id="%s"
kern_repo="%s"
fix_commit="%s" 
commit_id="%s"
syzkaller_id="%s"
config_url="%s"
log_url="%s"
report_url="%s"
syz_url="%s"
poc_url="%s"
'''
    content = template%(bug_id, kernel_map[kernel], fix_commit, k_id, syz_id, config_url, log_url, report_url,
                syz_url, poc_url)
    print(content)
    os.mkdir(ID)
    open(os.path.join(ID,'repro.cfg'),'w').write(content)

def get_if_has(tag, key='href'):
    if tag.a and key in tag.a.attrs.keys():
        return tag.a[key]
    return None

def get_bug_info(table, fix_commit, repro_flag):
    ID = 0
    trs = table.find_all('tr')
    # print(trs)
    for tr in trs:
        info = tr
        # print(info)
        if not info:
            continue
        # filter the first row in the table
        repro = info.find_all(class_='repro')
        if not repro:
            continue
        # set kernel_repro
        kernel_repro = info.find(class_='kernel').contents[0]
        if kernel_repro in close_kernel:
            continue
        # set commit_id
        href = info.find_all(class_='tag')[0].a['href']
        commit_id= ''
        if "id=" in href:
            commit_id = href.split('id=')[1]
        else:
            commit_id = href.split('/')[-1]
        # print(commit_id)
        # set syz_id
        syz_id = info.find_all(class_='tag')[1].a['href'].split('commits/')[1]
        # set config_url
        config_url = syzbot+info.find(class_='config').a['href']
        # set log_url
        log_url = syzbot+info.find_all(class_='repro')[0].a['href']
        report_url = syzbot+info.find_all(class_='repro')[1].a['href']
        # set syz_url
        syz_url = ''
        if get_if_has(info.find_all(class_='repro')[2]):
            syz_url = syzbot+get_if_has(info.find_all(class_='repro')[2])
        # set poc_url
        poc_url = ''
        if get_if_has(info.find_all(class_='repro')[3]):
            poc_url = syzbot+get_if_has(info.find_all(class_='repro')[3])
        if repro_flag and (not poc_url) and (not syz_url):
            continue
        ID += 1
        write_conf(kernel_repro, fix_commit, commit_id, syz_id, config_url, log_url, report_url,
                   syz_url, poc_url, str(ID))

def main(bug_id, repro):
    target = 'https://syzkaller.appspot.com/bug?id='+str(bug_id)
    content = urllib.request.urlopen(target).read()
    soup = BeautifulSoup(content, 'html.parser')
    commit = soup.find("span", {"class":"mono"})
    fix_commit = ''
    if get_if_has(commit):
        fix_commit = get_if_has(commit).split("?id=")[-1]
    # print(fix_commit)
    list_tables = soup.find_all(class_='list_table')
    for table in list_tables:
        caption = table.caption.contents[0].string
        if caption.startswith("Crash"):
            # print(table)
            get_bug_info(table, fix_commit, repro)

if __name__ == '__main__':
    if len(sys.argv) >= 2:
        bug_id = sys.argv[1]
    else:
        sys.exit(-1)
    # if True, only show reports with reproducers
    repro = (int(sys.argv[2]) == 1) if len(sys.argv) > 2 else True
    # print(repro)
    main(bug_id, repro)
