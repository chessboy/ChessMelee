//
//  LocalFileManager.swift
//  SwiftBots
//
//  Created by Robert Silverman on 10/17/18.
//  Copyright © 2018 fep. All rights reserved.
//

import Foundation

class LocalFileManager {
	
	static let shared = LocalFileManager()
		
	public func saveTrainingRecordsToFile(_ trainingRecords: [TrainingRecord], filename: String, fileExtension: String = "json") {

		do {
			let encoder = JSONEncoder()
			let data = try encoder.encode(trainingRecords)
			if let url = saveDataFile(filename, fileExtension: fileExtension, data: data) {
				print("saved saveState: \(url)")
			}

		} catch {
			print("could not encode saveState as \(filename).\(fileExtension): reason: \(error.localizedDescription)")
		}
	}
		
	private func createFileUrl(_ filename: String, create: Bool = false, fileExtension: String = "json") -> URL? {
		
		do {
			let documentDirectoryURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: create)
			return documentDirectoryURL.appendingPathComponent("\(filename).\(fileExtension)")
			
		} catch let error as NSError {
			print("could not create file URL: \(filename).\(fileExtension): reason: \(error.localizedDescription)")
		}
		
		return nil
	}
	
	func saveDataFile(_ filename: String, fileExtension: String = "json", data: Data) -> URL? {
		
		if let fileUrl = createFileUrl(filename, create: true, fileExtension: fileExtension) {
			
			do {
				try data.write(to: fileUrl, options: .atomic)
				//OctopusKit.logForSim.add("LocalFileManager.saveDataFile success: \(fileUrl)")
				return fileUrl
				
			} catch let error as NSError {
				print("could not save file: \(filename): reason: \(error.localizedDescription)")
			}
		}
		
		return nil
	}
	
	func loadDataFile<T: Decodable>(_ filename: String, fileExtension: String = "json", treatAsWarning: Bool = false) -> T? {
		
		if let fileUrl = createFileUrl(filename, fileExtension: fileExtension) {
			
			do {
				let data = try Data(contentsOf: fileUrl, options: .alwaysMapped)
				print("data file loaded successfully: \(fileUrl)")

				do {
					let decoder = JSONDecoder()
					return try decoder.decode(T.self, from: data)
				} catch {
					print("could not parse \(filename) as \(T.self):\n\(error)")
				}
				
			} catch let error as NSError {
				let errorDescription = "could not load contents of file \(filename): reason: \(error.localizedDescription)"
				if treatAsWarning {
					print(errorDescription)
				}
				else {
					print(errorDescription)
				}
			}
		}
		
		return nil
	}
	
	func deleteFile(_ fileUrl: URL) {
		
		do {
			try FileManager.default.removeItem(at: fileUrl)
			print("deleteFile: success: \(fileUrl)")
			
		} catch let error as NSError {
			
			if error.code != 4 {
				// ignore file not found
				print("deleteFile: error deleting file: \(fileUrl): error: \(error.localizedDescription), code: \(error.code)")
				
			} else {
				print("deleteFile: file not found: \(fileUrl)")
			}
		}
	}
	
	func deleteFile(_ filename: String, fileExtension: String = "json") {
		
		if let fileUrl = createFileUrl(filename, fileExtension: fileExtension) {
			deleteFile(fileUrl)
		}
	}
}
