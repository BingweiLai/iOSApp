//
//  StructMh.swift
//  bingweiApp
//
//  Created by Class on 2022/4/1.
//
import Foundation
struct SearchRespone : Codable{
    let result: ResponeStream
}
struct ResponeStream : Codable{
    //let lisght_list : [searchItem]
    let stream_list: [Item]
}
struct Item: Codable{
    let head_photo: URL
    let streamer_id: Int
    let tags: String
    let nickname: String
}
//WsJson-------------------------------------------------------------------------------------------
struct WsRespone : Codable {
    let event: String?
    let room_id: String?
    let sender_role: Int?
    let body: RoomSource?
    let time: String?
}
struct RoomSource : Codable{
    let chat_id: String?
    let account: String?
    let nickname: String?
    let recipient: String?
    let type: String?
    let text: String?
    let accept_time: String?
    let info: Obj?
    let content : adminMessage?
    let entry_notice : loginMessage?
}
struct Obj: Codable{
    let last_login: Int?
    let is_ban: Int?
    let level: Int?
    let is_guardian: Int?
    let badges: Bool?
}
struct adminMessage : Codable{
    let tw : String?
}
struct loginMessage : Codable{
    let username : String?
    let action : String?
}
