# Matlab tools for FVCOM

主要模块

1. PreProcess
2. PostProcess
3. Mesh
4. Time
5. Utility

## +PreProcess 前处理相关
前处理主要目的是生成FVCOM计算输入文件，包括
由于计算文件生成主要是面向过程，因此，函数式编程（将函数作为参数）最适合前处理类程序编写。

### +Mesh 网格相关
网格相关

### +Time
时间相关文件

```
./
├── get_julian_time.m
├── greg2julian.m
├── greg2mjulian.m
├── julian2greg.m
├── mjul2str.m
└── mjulian2greg.m
```

| func name       | comment                                                          |
| --------------- | ---------------------------------------------------------------- |
| get_julian_time | get julian time array                                            |
| greg2julian     | This function converts the Gregorian dates to Julian dates.      |
| greg2mjulian    | mjulianday = greg2mjulian(yyyy,mm,dd,HH,MM,SS)                   |
| julian2greg     | This function converts the Julian dates to Gregorian dates.      |
| mjul2str        | Convert a modified Julian day to a Matlab datestr style string   |
| mjulian2greg    | This function converts Modified Julian dates to Gregorian dates. |

`Matlab 自带工具箱中也有julian时间转换函数，与greg2mjulian结果相同`

```
timeNum = mjuliandate(startTimeStr,'yyyy-mm-dd HH:MM:SS')
```


