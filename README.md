
# Elastick & Kibana on Docker

Запуск `Elastick` & `Kibana` в `Docker Compose` и `Docker Swarm`.

Содержимое репозитория основано на [docker-elk](https://github.com/deviantony/docker-elk), но убирает `Logstash` и прочие штуки. Образы берутся из [docker hub](https://hub.docker.com/).

> Почему не `ELK`? ... так сложилось :)


## Цель

Изначальная цель - знакомство с `Elasticsearch`, позже потребовалось внедрение в `staging` среду кластера `Docker Swarm` (и только `staging`!).


## Использование

Для начала клонирование:
```bash
$ https://github.com/Byurrer/docker-ek.git
```

В файле `.env` определены основные конфиги:
* `ELASTIC_VERSION`
* `ELASTIC_PASSWORD`
* `KIBANA_SYSTEM_PASSWORD`

Образ `Setup` принимает еще одну переменную:
* `NEED_SHUTDOWN` - нужно ли останавливать контейнер, после того как он провел настройку или если настройка уже была совершена
    * `1` - для `localhost`
    * `0` - для `staging` среды в кластере `Docker Swarm`

> Пока другого способа для деплоя в `staging` не нашел. Простаивающий контейнер занимает ничтожное количество ресурсов, думаю не критично.

После поднятия сервисов, `Elasticsearch` будет доступен по `9200` порту, а `Kibana` на `5601`.

### Localhost

```bash
$ docker compose up
```

### Docker Swarm

`Docker Swarm` требует заранее подготовленные образы, поэтому нужно собрать. В файле [docker-compose.cluster.sample.yml](/docker-compose.cluster.sample.yml) приведен пример конфига для деплоя в `Docker Swarm`.

Собрать образы:

```bash
$ docker build --build-arg ELASTIC_VERSION=7.16.3 -t byurrer/elasticsearch:7.16.3 ./Elasticsearch
$ docker build --build-arg ELASTIC_VERSION=7.16.3 -t byurrer/kibana:7.16.3 ./Kibana
$ docker build --build-arg ELASTIC_VERSION=7.16.3 -t byurrer/ek-setup:7.16.3 ./Setup
```

И разместить в хранилище контейнеров доступном для `Docker Swarm`:

```bash
$ docker push byurrer/elasticsearch:7.16.3
$ docker push byurrer/kibana:7.16.3
$ docker push byurrer/setup:7.16.3
```

Теперь можно деплоить:

```bash
$ docker stack deploy -c docker-compose.cluster.yml ek
```
