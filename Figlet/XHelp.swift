//
//          File:   XHelp.swift
//    Created by:   African Swift

import Foundation
import XcodeKit

internal struct XHelp
{
  private var tags = (help: false)
  private var insertLine = 0
  internal private(set) var success: Bool
}

internal extension XHelp
{
  private mutating func findTags(invocation: XCSourceEditorCommandInvocation)
  {
    let lines = invocation.buffer.lines
    for i in 0..<lines.count
    {
      guard let line = lines[i] as? String else { continue }
      
      if line.contains("@help")
      {
        self.tags = (help: true)
        self.insertLine = i
        break
      }
    }
  }
}

internal extension XHelp
{
  private mutating func processHelp(invocation: XCSourceEditorCommandInvocation)
  {
    let lines = invocation.buffer.lines
    let bundle = Bundle.main()
    guard let path = bundle.pathForResource("XHelpmenu", ofType: ".txt"),
      let help = try? String(contentsOfFile: path, encoding: .utf8) else
    {
      return
    }

    let helplines = help.characters
      .split(separator: "\n", omittingEmptySubsequences: false)
      .map { String($0) }
    for i in helplines.indices
    {
      lines.insert("// " + helplines[i], at: self.insertLine + i)
    }
    self.success = true
  }
}

internal extension XHelp
{
  internal init(invocation: XCSourceEditorCommandInvocation)
  {
    self.success = false
    findTags(invocation: invocation)
    switch tags
    {
      case (true):
        processHelp(invocation: invocation)
      default:
        // play nothing to do sound
        print()
    }
  }
}
