
# imports #
import os
import std/strformat


let 
    username = getEnv("USER")
    path_home = "/home" / username

    path_working = getCurrentDir()

    path_apps = path_home / ".local/share/applications"
    path_bin = path_home / ".local/bin"


proc fatalError(message: string, code: int = 1): void {.noreturn.} =
    echo "ERROR: ", message
    quit(code)


proc findAppimage(path_to_file: string): string =
    if fileExists(path_working/path_to_file):
        return path_working/path_to_file

    fatalError("That file doesnt exist!")


proc findIcon(path_to_icon: string): string =
    if fileExists(path_working/path_to_icon):
        return path_working/path_to_icon

    fatalError("That icon doesnt exist!")


proc makeRequiredDirs(file_name: string): void =
    createDir( path_apps )
    createDir( path_bin )

    createDir( path_bin/file_name )

    return


proc newDesktopEntry(file_name, icon_name: string): string =
    return(fmt"""
[Desktop Entry]
Name={file_name}
Comment={file_name}
Exec="{path_bin/file_name/file_name}.AppImage"
Terminal=false
Type=Application
Icon={path_bin/file_name}/{icon_name}.png
Categories=none
"""
    )


proc getFileName(file_path: string ): string =
    # fix this later
    for i in (0..file_path.high):
        if (file_path[i] == '/'): result = ""
        else: result.add(file_path[i])

    let extension_index = result.find('.')
    return result[0 .. (extension_index-1)]


proc moveToCorrectDir(folder_name, file_path, file_name, extension: string): void =
    try: moveFile(
        file_path, 
        path_bin / folder_name / file_name & extension
    )

    except OSError as e: fatalError(e.msg, -1)

    return


proc main(): void =
    let params = commandLineParams()

    case params.len():
    of 0: fatalError(
        "Requires your appimage file and icon"
    )
    of 1: fatalError(
        "Requires your icon"
    )
    else: discard

    let file_path = findAppimage(params[0])
    let file_name = getFileName(file_path)

    let icon_path = findIcon(params[1])
    let icon_name = getFileName(icon_path)

    makeRequiredDirs(file_name)

    moveToCorrectDir(file_name, file_path, file_name, ".AppImage")
    moveToCorrectDir(file_name, icon_path, icon_name, ".png")

    let desktopFileText = newDesktopEntry(file_name, icon_name)
    writeFile(path_apps/file_name&".desktop", desktopFileText)

    return


when is_main_module: main()