# YY-CHR Plugins

A selection of plugins for the graphics editor YY-CHR.NET. The following plugins are currently available:

**XaviXFormat** - Edit XaviX formatted tiles found in rad_sbw.

## Installing Plugins

To install a plugin, download it from the [releases](https://github.com/widberg/rad_sbw/releases/latest) page and unzip the dll file to the `Plugins` folder of your YY-CHR installation.

## Building Plugins

Download or clone this repository. Copy `CharactorLib.dll` from `yychr` to `XaviXFormat`. Open the solution file (`.sln`) for the given plugin in Visual Studio. From the main menu select `Build > Build Solution`. The resulting `dll` file is written to `bin\Debug`. Move the `dll` to the `Plugins` folder under your YY-CHR installation directory and open the app. (Tested in Microsoft Visual Studio Community 2022.)

## Other Plugins

Other open-source plugins for YY-CHR I found while searching GitHub for [`language:C# CharactorLib`](https://github.com/search?q=language%3AC%23+CharactorLib&type=code). They aren't related to XaviX, but they're good reference material.

* https://github.com/gzip/cs-yychr-plugins
* https://github.com/freem/freemlib-neogeo/tree/master/tools/yy-chr_plugins
* https://github.com/mrdion/CPS1-tools
