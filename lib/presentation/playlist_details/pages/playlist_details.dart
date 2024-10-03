import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_project/common/widgets/appbar/app_bar.dart';
import 'package:spotify_project/core/configs/assets/app_images.dart';
import 'package:spotify_project/presentation/playlist_details/bloc/playlist_details_cubit.dart';

import '../../../domain/entities/playlist/playlist.dart';
import '../../../domain/entities/song/song.dart';
import '../bloc/playlist_details_state.dart';

class PlaylistDetailsPage extends StatelessWidget {
  final PlaylistEntity playlist;
  const PlaylistDetailsPage({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppBar(
        title: Text('Playlist Details'),
      ),
      body: Column(
        children: [
          _playlistHeader(playlist),
          BlocProvider(
            create: (context) =>
                PlaylistDetailsCubit()..fetchPlaylistDetails(playlist.songURLs),
            child: BlocBuilder<PlaylistDetailsCubit, PlaylistDetailsState>(
              builder: (context, state) {
                if (state is PlaylistDetailsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is PlaylistDetailsLoaded) {
                  return Column(
                    children: [
                      _songs(state.songs),
                    ],
                  );
                } else if (state is PlaylistDetailsLoadFailure) {
                  return Center(
                    child: Text(state.message),
                  );
                } else {
                  return const Center(
                    child: Text(' Something went wrong'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _playlistHeader(PlaylistEntity playlist) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  
                  borderRadius: BorderRadius.circular(10),
                  image: playlist.imageURL != null
                      ? DecorationImage(
                        fit: BoxFit.cover,
                          image: NetworkImage(playlist.imageURL!),
                        )
                      : const DecorationImage(
                        fit: BoxFit.cover,
                          image: AssetImage(AppImages.albumCover),
                        ),
                ),
              ),
              SizedBox(width: 30,),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('${playlist.songURLs!.length} songs',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w200,
                      )),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(playlist.description!,style: 
          TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w200,
          )
          ,)
        ],
      ),
    );
  }

  Widget _songs(List<SongEntity> songs) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemBuilder: ((context, index) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/song-player', arguments: {
            'songs': songs,
            'index': index,
          }),
          child: ListTile(
            tileColor: Colors.transparent,
            selected: false,
            leading: Image.network(songs[index].coverURL),
            title: Text(songs[index].title),
            subtitle: Text(
              songs[index].artist,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: songs.length,
    );
  }
}
