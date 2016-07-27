//
//          File:   XFigfont.swift
//    Created by:   African Swift

import Foundation
import XcodeKit

internal struct XFigfont
{
  private var tags = (font: false, text: false, list: false)
  private var font = ""
  private var title = ""
  private var insertLine = 0
  internal private(set) var success: Bool
}

internal extension XFigfont
{
  private mutating func findTags(invocation: XCSourceEditorCommandInvocation)
  {
    let lines = invocation.buffer.lines
    for i in 0..<lines.count
    {
      guard let line = lines[i] as? String else { continue }
      let length = line.characters.count
      
      if line.contains("@figfont")
      {
        self.font = line.substring(with: 11..<length)?.trim() ?? ""
        self.tags = (font: true, text: self.tags.text, list: false)
        self.insertLine = i
        if self.tags == (font: true, text: true, list: false)
        {
          break
        }
      }
      
      if line.contains("@figtext")
      {
        let t = "@figtext ".characters.count
        let i = line.index(of: "@") ?? t + 4
        self.title = line.substring(with: i + t..<length) ?? ""
        self.tags = (font: self.tags.font, text: true, list: false)
        if self.tags == (font: true, text: true, list: false)
        {
          break
        }
      }
      
      if line.contains("@figlist")
      {
        self.insertLine = i > 0 ? i - 1 : 0
        self.tags = (font: false, text: false, list: true)
        break
      }
    }
  }
}

internal extension XFigfont
{
  private mutating func processFont(invocation: XCSourceEditorCommandInvocation)
  {
    let lines = invocation.buffer.lines
    let bundle = Bundle.main()
    guard let fontpath = bundle.pathForResource(self.font, ofType: ".flf"),
      let font = try? Figlet(fontFile: fontpath.trim()),
      let figtext = font?.drawText(text: title)
      else {
        return
    }

    for i in figtext.indices
    {
      lines.insert("// " + figtext[i] , at: self.insertLine + i)
    }
    self.success = true
  }
  
  private mutating func processList(invocation: XCSourceEditorCommandInvocation)
  {
    let lines = invocation.buffer.lines
    let bundle = Bundle.main()
    let fontpath = bundle.pathsForResources(ofType: ".flf", inDirectory: "")
    let fonts = fontpath
      .map { ($0 as NSString).lastPathComponent }
      .joined(separator: ", ")
      .replacingOccurrences(of: ".flf", with: "")
    lines.insert("// available fig fonts: " + fonts, at: self.insertLine)
    self.success = true
  }
}

internal extension XFigfont
{
  internal init(invocation: XCSourceEditorCommandInvocation)
  {
    self.success = false
    findTags(invocation: invocation)
    switch tags
    {
    case (false, false, true):
      processList(invocation: invocation)
    case (true, true, false):
      processFont(invocation: invocation)
    default:
      // play nothing to do sound
      print()
    }
  }
}
