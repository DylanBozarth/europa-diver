//
//  Scannable.swift
//  europa-diver
//
//  Anything the scan ability can target — must report where it is and a
//  stable per-species identity for the survey log.
//

import CoreGraphics

protocol Scannable: AnyObject {
    var position: CGPoint { get }
    var speciesID: String { get }
}
