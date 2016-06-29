//
//  SourceEditorCommand.swift
//  Figlet
//
//  Created by Vaughn on 2016/06/24.
//  Copyright © 2016 africanswift. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
  
  func perform(
    with invocation: XCSourceEditorCommandInvocation,
    completionHandler: (NSError?) -> Void ) -> Void
  {
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    
    var result = (font: false, help: false, other: false)
    
    var updatedLineIndexes = [Int]()
    
    // Figlet font tags
    let figfont = XFigfont(invocation: invocation)
    result.font = figfont.success
    
    // Help tag
    let help = XHelp(invocation: invocation)
    result.help = help.success
    
    switch result
    {
    case (false, false, true):
      print("other")
    case (true, false, false):
      print("font processed")
    case (false, true, false):
      print("help processed")
    default:
      print("failed")
    }

    updatedLineIndexes.append(0)
    updatedLineIndexes.append(1)
    
    let updatedSelections: [XCSourceTextRange] = updatedLineIndexes.map { lineIndex in
      let lineSelection = XCSourceTextRange()
      lineSelection.start = XCSourceTextPosition(line: lineIndex, column: 0)
      lineSelection.end = XCSourceTextPosition(line: lineIndex, column: 0)
      return lineSelection
    }
    
    if updatedSelections.count > 0 {
      invocation.buffer.selections.setArray(updatedSelections)
    }
    
    completionHandler(nil)
  }
  
}
