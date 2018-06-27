//
//  GraphFiles.swift
//  memorydumper2
//
//  Created by Nuno Patraquim on 10/06/2018.
//  Copyright © 2018 mikeash. All rights reserved.
//

import Foundation

struct GraphFiles {

    fileprivate static var graphFiles: GraphFiles?

    private enum Constants {

        static let defaultPath = "/tmp/"
        static let defaultFileExtension = "pdf"
        static let defaultShellLocation = "/usr/local/bin/dot"
    }

    let path: String
    let fileExtension: String
    let dotShellLocation: String?

    let shouldConvertFiles: Bool

    init(path: String?,
         fileExtension: String?,
         dotShellLocation: String?,
         shouldConvertFiles: Bool?) {

        self.path = path ?? Constants.defaultPath
        self.fileExtension = fileExtension ?? Constants.defaultFileExtension
        self.dotShellLocation = dotShellLocation
        self.shouldConvertFiles = shouldConvertFiles ?? false
    }

    static func sharedInstance() -> GraphFiles {

        if let sharedInstance = self.graphFiles {

            return sharedInstance

        } else {

            initGraphFiles()

            return graphFiles!
        }
    }
}

//MARK: Prepare sharedInstance

fileprivate extension GraphFiles {

    static func initGraphFiles() {

        let arguments = CommandLine.arguments
        var filesPath: String?
        var filesExtension: String?
        var dotShellLocation: String?
        var shouldConvertFiles: Bool?

        for argument in arguments {

            if argument.range(of:"path:") != nil {

                let filesPathArray = argument.components(separatedBy: ":")
                filesPath = filesPathArray.count > 1 ? filesPathArray[1] : nil
            }

            if argument.range(of:"fileExtension:") != nil {

                let filesExtensionArray = argument.components(separatedBy: ":")
                filesExtension = filesExtensionArray.count > 1 ? filesExtensionArray[1] : nil
            }

            if argument.range(of:"dotShellLocation:") != nil {

                let dotShellLocationArray = argument.components(separatedBy: ":")
                dotShellLocation = dotShellLocationArray.count > 1 ? dotShellLocationArray[1] : nil
            }

            if argument.range(of:"shouldConvertFiles:") != nil {

                let shouldConverFilestArray = argument.components(separatedBy: ":")
                shouldConvertFiles = shouldConverFilestArray.count > 1 ? Bool(shouldConverFilestArray[1]) : nil
            }
        }

        self.graphFiles = GraphFiles(path: filesPath, fileExtension: filesExtension, dotShellLocation: dotShellLocation, shouldConvertFiles: shouldConvertFiles)

        self.log(path: filesPath, fileExtension: filesExtension, dotShellLocation: dotShellLocation, shouldConvertFiles: shouldConvertFiles)
    }
}

//MARK: Export dot files

extension GraphFiles {

    static func export(filename: String) {

        guard self.sharedInstance().shouldConvertFiles else {

            return
        }

        let task = Process()
        task.launchPath = self.sharedInstance().dotShellLocation
        task.arguments = commandToRun(for: filename)
        task.launch()
    }

    fileprivate static func commandToRun(for fileName: String) -> [String] {

        guard let graphFiles = self.graphFiles else {

            return []
        }

        return ["-T" + graphFiles.fileExtension,
                graphFiles.path + fileName + ".dot",
                "-o",
                graphFiles.path + fileName + "." + graphFiles.fileExtension]
    }
}

//MARK: Log

fileprivate extension GraphFiles {

    static func log(path: String?, fileExtension: String?, dotShellLocation: String?, shouldConvertFiles: Bool?) {

        guard shouldConvertFiles != nil else {

            print("If you want to convert your dot files you should specify \"shouldConvertFiles:true\". The default is false. \n")
            return
        }

        if path == nil {

            print("You can specify where you want to keep your files by adding \"path:...\".\n")
        }

        if fileExtension == nil {

            print("You can convert your dot files to other types by specifing \"fileExtension:...\". The default one is pdf.\n")
        }

        if dotShellLocation == nil {

            print("For the exportion process to work you should specify the dot shell location by specifing \"dotShellLocation:...\". If you have installed GraphViz through Homebrew it should be at this location: /usr/local/bin/dot \n")
        }
    }
}
