//
//  DouBanNetworkService.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/17.
//  Copyright © 2020 NULL. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class DouBanNetworkService {
    func loadChannels() -> Observable<[Channel]> {
        return DouBanProvider.rx.request(.channels)
            .mapObject(Douban.self)
            .map{ $0.channels ?? [] }
            .asObservable()
    }
    
    func loadPlaylist(_ channelId: String) -> Observable<Playlist> {
        return DouBanProvider.rx.request(.playList(channelId))
            .mapObject(Playlist.self)
            .asObservable()
    }
    
    func loadFirstSong(_ channelId: String) -> Observable<Song> {
        return loadPlaylist(channelId)
            .filter{ $0.song.count > 0}
            .map{ $0.song[0] }
    }
}
