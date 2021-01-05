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
		
	public func saveTrainingRecordsToCsvFile(_ trainingRecords: [TrainingRecord], for pieceType: PieceType) {
		let fileExtension = "csv"
		let filename = "training-\(pieceType.description)"

		var rawText = ""
		var columnText = ""
		let columnCount = pieceType.visionDimension * pieceType.visionDimension - 1
		for column in stride(from: 0, to: columnCount, by: 1) {
			columnText += "inputs_\(column),"
		}
		
		rawText += "\(columnText)picker,output\n"
		for trainingRecord in trainingRecords {
			rawText += trainingRecord.inputs.map({ String($0) }).joined(separator: ",") + ",\(trainingRecord.output)\n"
		}
		
		if let data = rawText.data(using: .nonLossyASCII) {
			if let url = saveDataFile(filename, fileExtension: fileExtension, data: data) {
				print("saved saveState: \(url)")
			}
		} else {
			print("could not encode training records as nonLossyASCII to \(filename).\(fileExtension)")
		}
	}
	
	public func loadTrainingRecordsFromCsvFile(for pieceType: PieceType) -> [TrainingRecord] {
		let fileExtension = "csv"
		let filename = "training-\(pieceType.description)"

		var trainingRecords: [TrainingRecord] = []
		if let fileUrl = createFileUrl(filename, fileExtension: fileExtension) {
			
			do {
				let contents = try String(contentsOf: fileUrl, encoding: .nonLossyASCII)
				let lines = contents.split(separator:"\n")
				for line in lines {
					let splits = line.split(separator: ",")
					if let outputString = splits.last, let output = Int(outputString) {
						let inputStrings: [String] = splits.prefix(splits.count - 1).map({ String($0) })
						let inputs = inputStrings.map({ Int($0) ?? 0 })
						let trainingRecord = TrainingRecord(inputs: inputs, output: output)
						trainingRecords.append(trainingRecord)
					}
				}
			} catch let error {
				print("could not read file: \(filename).\(fileExtension), error: \(error.localizedDescription)")
			}
		}

		return trainingRecords
	}

	public func saveTrainingRecordsToJsonFile(_ trainingRecords: [TrainingRecord], for pieceType: PieceType) {
		let fileExtension = "json"
		let filename = "training-\(pieceType.description)"

		do {
			let encoder = JSONEncoder()
			let data = try encoder.encode(trainingRecords)
			if let url = saveDataFile(filename, fileExtension: fileExtension, data: data) {
				print("saved saveState: \(url)")
			}

		} catch {
			print("could not encode training records as \(filename).\(fileExtension): reason: \(error.localizedDescription)")
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
	
	func loadJsonFile<T: Decodable>(_ filename: String, treatAsWarning: Bool = false) -> T? {
		let fileExtension = "json"

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
