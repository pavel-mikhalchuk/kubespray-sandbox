# kubespray

## Перед началом запуска

0. Тебе просто необходимо немного ознакомится с [Ansible](https://www.ansible.com/resources/get-started), чтобы научится читать структуру и имена папок и файлов этого проекта.

1. Убедись, что ./kubespray git подмодуль выкачан. Почитай как выкачивать git sub-modules. [Тут](https://stackoverflow.com/questions/3796927/how-to-git-clone-including-submodules) или [тут](https://stackoverflow.com/questions/1030169/easy-way-to-pull-latest-of-all-git-submodules).

1. Набор виртуалок с установленной Ubuntu 18.04.

1. SSH ключи того пользователя, который запускает kubespray должны быть скопированы на все виртуалки. Это необходимо kubespray для безпарольного доступа к ним. Пользователь должен иметь root права на каждой машине. В случае, если сис админы не обеспечили безпарольный доступ для пользователя, который запускает kubespray, но есть парольный доступ,то нужно сгенерировать SSH ключи и скопировать их на все виртуалки. Тогда появится безпарольный доступ. Смотри README.MD в папке ssh-utils/keys. Еще очень важно, чтобы на виртуалках твой пользователь мог стать рутом (через sudo su, например) без ввода пароля. Если необходимо вводить пароль, то Ansible завалится. Об этом опять же должны позаботиться админы перед тем, как отдавать тебе виртуалки. Но если и тут косяк тогда гугли как сделать пользователя рутом без пароля (https://askubuntu.com/questions/147241/execute-sudo-without-password).

   > Open terminal window and type:
   >
   > `sudo visudo`
   >
   > In the bottom of the file, type the follow:
   >
   > `$USER ALL=(ALL) NOPASSWD: ALL`

## IP адреса виртуалок

В корневой папке проекта есть файл `hosts.ini`, в котором надо указать ip адреса всех виртуалок. Так указать кто мастер и кто воркер.

## Запуск деплоймента kubernetes кластера

1. Для того, чтобы запустить kubespray мы будем использовать docker образ, созданный на базе файлика `Dockerfile_kubespray`. (**На момент 9.02.2019 я [Павел Михальчук] планирую сделать этот образ доступным для использования в нашем приватном docker registry. Поэтому перед тем как собирать docker образ самостоятельно проверь нет ли уже его в нашем docker registry. Но если же ты сам делаешь изменения в этом репозитории, которые могут затронуть Dockerfile_kubespray, тогда тебе точно надо собирать его руками.**).

   Собираем docker образ:

   > `docker build -t kubespray -f Dockerfile_kubespray .`

2. Запускаем kubespray:

   Полагаем, что:

   - Админы создали нам на каждой виртуалке пользователя **infra**.
   - У тебя есть ssh ключи для безпарольного доступа пользователя **infra** на все виртуалки. Ключи находятся на твоей машине тут - `/home/infra/.ssh/`.
   - На всех виртуалках пользователь **infra** может стать root без введения пароля.<br/><br/>

   > `docker run --rm -e "USER=infra" -v /home/infra/.ssh/:/host_ssh kubespray ansible-playbook --become --become-user=root master_playbook.yml`

   Пояснения:

   > `-e "USER=infra"` - мы запускаем kubespray от лица пользователя **infra**

   > `-v /home/infra/.ssh/:/host_ssh` - указываем путь к ssh ключам пользователя **infra** на твоей машине. `/host_ssh` используется в `scripts/kubespray-entrypoint.sh`.

   > `--become --become-user=root` - это настройки Ansible для того, чтобы стать рутом на виртуалках.

## Получение admin конфигурации созданного kubernetes кластера

1. Способ влоб: если у тебя есть доступ к одной из master нод, то конфиг можно вытянуть прямо оттуда: `/root/.kube/config`

2. С помощью Ansible:

   > `docker run --rm -e "USER=infra" -v /home/infra/.ssh/:/host_ssh -v /home/infra/kubespray-artifacts:/kubespray/artifacts kubespray ansible-playbook --become --become-user=root kubespray/cluster.yml --tags=client`

   Пояснения:

   > `-v /home/infra/kubespray-artifacts:/kubespray/artifacts` - до `:` это папка на твоей машине куда будет записан конфиг кластера. После `:` это папка в docker контейнере куда Ansible складывает конфиг кластера. **ВНИМАНИЕ: На твоей машине получившийся файл конфига может быть не доступен твоему пользователю, от которого ты запускаешь Ansible. Не забудь подкрутить это, если нужно.**

   > `--tags=client` - это ключевой момент здесь. Намерение получить клиентский конфиг кластера.

## Немного о плейбуках, которые есть на данный момент

На данный момент (3.03.2019) У нас есть главный плейбук, который называется `master_playbook.yml`.

У него есть два дочерних плейбука:

1. `kubespray/cluster.yml` - оригинальный плейбук от kubespray, который занимается исключительно созданием kubernetes кластера. Также с помощью него можно вытянуть admin конфиг, добавить или убрать ноду, обновить вресию kubernetes и прочее. Смотри документацию [kubespray](https://github.com/kubernetes-sigs/kubespray).

2. `kube.yml` - наш собственный плейбук для деплоймента всего того, что нам необходимо в нашем кластере (kube dashboard, nginx ingress, heapster, prometheus, zipkin, и т.д.)

## Разворачивание внутрикубовой инфраструктуры Алютех

Для этого мы будем использовать плейбук `kube.yml`.

Есть два способа:

1. **Быстрый, хорошо подходит для того, кто работает над `kube.yml`, когда надо часто деплоить в кластер**. У тебя уже должен быть admin конфиг kubernetes кластера. Предположим твоего пользователя зовут `infra` и конфиг сложен в папку - `/home/infra/.kube/`.

   > `docker run --rm -e "USER=infra" -v /home/infra/.kube/:/host_kube_config kubespray ansible-playbook kube.yml`

   **ВАЖНО**: файл кофига должен иметь имя `config`.

2. **Медленный, хорошо подходит для одноразового запуска для деплойментв в существующий кластер**. У тебя нет admin кофига kubernetes кластера.

   > `docker run --rm -e "USER=infra" -v /home/infra/.ssh/:/host_ssh kubespray ansible-playbook --become --become-user=root master_playbook.yml --tags=client`

   Пояснения: т.е. сначала kubespray сам сходит на master ноду, заберет admin конфиг, мы его складываем в нужную папку в нашем docker контейнере и уже потом начинаем деплойменты описанные в `kube.yml`.

## Уничтожение kubernetes кластера

Для этого мы будем использовать плейбук `kubespray/reset.yml`.

> `docker run --rm -e "USER=infra" -v /home/infra/.ssh/:/host_ssh kubespray ansible-playbook --become --become-user=root -e reset_confirmation=yes --flush-cache kubespray/reset.yml`

Не вдаваясь в подробности этот плейбук сносит docker и kubelet сервисы. В итоге все запущеное на нодах, что связаное с kubernetes останавливается. 

За более подбродной информацией смотрите плейбук.

## Разворачивание внекубового NFS сервера

Для этого мы будем использовать плейбук `nfs-server.yml`.

> `docker run --rm -e "USER=infra" -v /home/infra/.ssh/:/host_ssh kubespray ansible-playbook --become --become-user=root nfs-server.yml`
