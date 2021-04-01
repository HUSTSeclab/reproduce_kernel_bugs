# Reproduction Deployment and Testing

## Preparation

- Download some linux git repositories in `Kernel_repos`(e.g., Kernel_repos/linux for upstream);
- Download and install go;
- Download `Images` from remote source(e.g., Google Drive) or manually generate Debian images with `create-image.sh`;

```
mkdir -p Kernel_repos
cd Kernel_repos/
./download_repos.sh
cd ..

cd Go_pkg/
./install_go.sh
cd ..

mkdir Images
cd Images
./download_image.sh
cd ..
```

## Environment deployment

1. Create a directory with the bug id from syzkaller;
2. Change to the corresponding working directory. There can be multiple crash entries for each syzkaller id;
3. Deploy the essential environment; (You may need to press "Enter" when building the kernel)

```
./deploy_case.sh $syzkaller_id$
cd $syzkaller_id$/1/ ; use the 1stcrash entry by default
./deploy_repro.sh
```

## Testing

First, start QEMU VM, then copy PoC or syz file to QEMU VM; Second, connect QEMU VM when ready, execute PoC or syz file in QEMU VM;

If `poc.c` exists,

- Copy `poc.c` into QEMU VM;
- Compile and execute `poc.c` in the QEMU VM;

else,

- Copy `repro_in_vm`, `syz-execprog`, `sys-executor` and `log` into QEMU VM;
- Modify the options in `repro_in_vm` and execute it in the QEMU VM;

## Environment after executing deploy_case.sh

Take `ddc83e209f712ce63078e146f7c0fe63e1edbc2f` as an example,

```
ddc83e209f712ce63078e146f7c0fe63e1edbc2f
└── 1
    ├── deploy_repro.sh
    └── repro.cfg
└── 2
    ├── deploy_repro.sh
    └── repro.cfg
└── ...
└── 20
    ├── deploy_repro.sh
    └── repro.cfg
```

`deploy_repro.sh` and `repro.cfg` are used to automatically deploy the reproduction environment;

### Demo of repro.cfg

```
bug_id="ddc83e209f712ce63078e146f7c0fe63e1edbc2f"
kern_repo="linux"
commit_id="6f70eb2b00eb416146247c65003d31f4df983ce0"
syzkaller_id="05b5a32cfd918a0049f5657a6474ec3b08694093"
config_url="https://syzkaller.appspot.com/text?tag=KernelConfig&x=1a61309a3b712fa5"
log_url="https://syzkaller.appspot.com/text?tag=CrashLog&x=13113dc3800000"
report_url="https://syzkaller.appspot.com/text?tag=CrashReport&x=165af3f3800000"
syz_url="https://syzkaller.appspot.com/text?tag=ReproSyz&x=16766f83800000"
poc_url="https://syzkaller.appspot.com/text?tag=ReproC&x=11434d53800000"
```

`bug_id`       : the bug id from syzkaller    
`kern_repo`    : kernel repo (e.g., linux for the folder name in the Kernel_repos)     
`commit_id`    : commit id for the corresponding kernel git repo    
`syzkaller_id` : commit id for syzkaller git repo   
`config_url`   : the url of kernel configuration file    
`log_url`      : the url of krenel log file    
`report_url`   : the url of crash report file    
`syz_url`      : the url of syz file    
`poc_url`      : the url of poc file    

## Environment after executing deplay_repro.sh

```
ddc83e209f712ce63078e146f7c0fe63e1edbc2f
└── 1
    ├── backup
    ├── bin
    ├── config
    ├── connectvm
    ├── debugvm
    ├── deploy_repro.sh
    ├── gopath
    ├── image
    ├── linux
    ├── log
    ├── poc.c
    ├── README
    ├── report
    ├── repro.cfg
    ├── repro_in_vm
    ├── scptovm
    ├── startvm
    └── syz
```

- `backup` saves the copy of kernel source code package;    
- `bin` includes all the useful syzkaller tools;    
- `config` is kernel configuration downloaded from syzkaller dashboard;    
- `connectvm, debugvm, scptovm, scpfromvm, repro_in_vm, startvm` are useful scripts copied from Scripts in the root directory;    
- `cscope.out` is the metadata for cscope in the Linux kernel;
- `deploy_env.sh` and `repro.cfg` are used to automatically deploy the reproduction environment;    
- `gopath` records source code for the specific commit of syzkaller;    
- `image` stores debian image copied from Images in the root directory;    
- `linux` is the directory for compiled kernel source code;    
- `log` is downloaded from the syzkaller dashboard;    
- `report` is downloaded from the syzkaller dashboard;    
- `syz` or `poc.c` is used to reproduce the corresponding crash;    

## References

[1] [Go and syzkaller](https://github.com/google/syzkaller/blob/master/docs/linux/setup.md#go-and-syzkaller)
[2] [Download and install go](https://golang.org/doc/install)
