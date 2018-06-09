import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


Future<List<Repo>> fetchRepo(http.Client client) async {
  final response =
      await client.get("https://api.github.com/users/yogiwisesa/repos");

  return compute(parseRepo, response.body);
}

class Repo {
  final String name, description, language, url;

  Repo({this.name, this.description, this.language, this.url});

  factory Repo.fromJson(Map<String, dynamic> json) {
    return new Repo(
        name: json["name"],
        description: json["description"] != null ? json["description"] : "-",
        language: json["language"],
        url: json["html_url"]);
  }
}

List<Repo> parseRepo(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Repo>((json) => new Repo.fromJson(json)).toList();
}

void main() => runApp(new GithubRepository());

class GithubRepository extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ;

    return new MaterialApp(
      title: "Github",
      home: new HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Github"),
      ),
      body: new FutureBuilder<List<Repo>>(
        future: fetchRepo(new http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? new ReposList(repos: snapshot.data)
              : new Center(
                  child: new CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}

class ReposList extends StatelessWidget {
  final List<Repo> repos;

  ReposList({Key key, this.repos}) : super(key: key);

  void openBroser(String url) async{
    await launch(url);
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: repos.length,
      itemBuilder: (context, index) {
        return new ListTile(
          title: new Text(
            "${repos[index].name} (${repos[index].language}",
            style: new TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: new Text(repos[index].description),
          onTap: () {
            Scaffold.of(context).showSnackBar(
                new SnackBar(content: new Text("Opening ${repos[index].name}")));
                openBroser(repos[index].url);
          },
        );
      },
    );
  }
}
