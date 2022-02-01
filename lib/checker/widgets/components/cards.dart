import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:league_checker/checker/widgets/modals/add_summoner.dart';
import 'package:league_checker/checker/widgets/modals/summoner_viewer.dart';
import 'package:league_checker/repositories/checker_repository.dart';
import 'package:league_checker/model/summoner_model.dart';
import 'package:league_checker/style/color_palette.dart';
import 'package:league_checker/style/stylesheet.dart';
import 'package:league_checker/utils/spacer.dart';
import 'package:league_checker/utils/waiter.dart';
import 'package:provider/provider.dart';

class CardEmpty extends StatelessWidget {
  const CardEmpty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late CheckerRepository checkerRepository;
    checkerRepository = Provider.of<CheckerRepository>(context);

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: darkGrayTone2,
              child: InkWell(
                onTap: () {
                  showRemoveSummoner(context, checkerRepository);
                },
                child: SizedBox(
                  width: (checkerRepository.width / 2) - 80,
                  height: 102,
                  child: const Icon(
                    Icons.delete_outline,
                    size: 40,
                    color: grayTone1,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 30, left: 5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: grayTone2,
              child: InkWell(
                onTap: () {
                  showAddSummoner(context);
                },
                child: SizedBox(
                  width: (checkerRepository.width / 2) + 10,
                  height: 102,
                  child: const Icon(
                    Icons.add,
                    size: 40,
                    color: grayTone1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  showAddSummoner(context) async {
    showModalBottomSheet(
      barrierColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      backgroundColor: darkGrayTone2,
      builder: (BuildContext context) {
        return const AddSummoner();
      },
    );
  }

  showRemoveSummoner(context, checkerRepository) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove all favorited Summoners?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                checkerRepository.removeSummonerList();
                Navigator.pop(context);
              },
              child: const Text('REMOVE'),
            )
          ],
        );
      },
    );
  }
}

class CardSummoner extends StatefulWidget {
  const CardSummoner({Key? key, required this.summoner}) : super(key: key);

  final SummonerModel summoner;

  @override
  _CardSummonerState createState() => _CardSummonerState();
}

class _CardSummonerState extends State<CardSummoner> {
  late CheckerRepository checkerRepository;

  bool retrievingCardUser = false;

  @override
  Widget build(BuildContext context) {
    checkerRepository = Provider.of<CheckerRepository>(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 30, right: 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            openSummonerCard(widget.summoner.name, widget.summoner.region);
          },
          child: Container(
            color: darkGrayTone2.withOpacity(0.4),
            height: 170,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                      "http://ddragon.leagueoflegends.com/cdn/img/champion/splash/${widget.summoner.background}_0.jpg"),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    horizontalSpacer(15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.black87, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              width: 60,
                              height: 60,
                              imageUrl:
                                  "http://ddragon.leagueoflegends.com/cdn/11.23.1/img/profileicon/${widget.summoner.profileIconId}.png",
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(
                                color: grayTone1,
                                strokeWidth: 10,
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Ink(
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Center(
                                  child: Text(
                                    widget.summoner.summonerLevel.toString(),
                                    style: textSmallBold,
                                  ),
                                ),
                                horizontalSpacer(10),
                                Image.asset(
                                  "assets/images/regions/regionFlag-${widget.summoner.region}.png",
                                  width: 20,
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    const Spacer(),
                    Text(
                      widget.summoner.name,
                      style: textMediumBold,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  openSummonerCard(summonerName, region) async {
    if (!checkerRepository.isLoadingSummoner) {
      setState(() => retrievingCardUser = true);
      await checkerRepository.selectRegion(region);
      var response = await checkerRepository.getSummonerData(summonerName);
      if (response == 200) {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return const SummonerViewer();
          },
          backgroundColor: primaryDarkblue,
          isScrollControlled: true,
        );
      } else {
        checkerRepository.setError("Summoner from different region");
      }
      await wait(200);
      setState(() => retrievingCardUser = false);
    }
  }
}
