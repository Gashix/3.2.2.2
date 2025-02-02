# Стадия сборки
FROM golang:1.19-alpine AS builder

WORKDIR /app

# Копируем файлы модулей и скачиваем зависимости
COPY go.mod go.sum ./
RUN go mod download

# Копируем исходный код
COPY . .

# Компилируем приложение
RUN CGO_ENABLED=0 GOOS=linux go build -o server .

# Стадия выполнения
FROM alpine:latest

WORKDIR /root/

# Копируем скомпилированное приложение из builder контейнера
COPY --from=builder /app/server .
COPY .env .

# Указываем порт
EXPOSE 8080

# Запускаем приложение
CMD ["./server"]


# 1. Стадия сборки (Builder Stage)
# Стадия сборки используется для компиляции Go-приложения. Она включает в себя все необходимые шаги для сборки приложения, такие как загрузка зависимостей и компиляция кода. Весь процесс сборки выполняется в отдельном контейнере, который после компиляции может быть удалён.

# Детали:
#     FROM golang:1.19-alpine AS builder:
    
#     Использует образ golang:1.19-alpine в качестве базового для сборки.
#     Использование alpine минимизирует размер образа за счёт использования Alpine Linux.
#     Ключевое слово AS builder даёт имя этому этапу, чтобы можно было сослаться на него позже.
#     WORKDIR /app:
    
#     Устанавливает рабочую директорию для всех последующих команд в /app.
#     COPY go.mod go.sum ./:
    
#     Копирует файлы go.mod и go.sum, которые содержат информацию о зависимостях, в рабочую директорию контейнера.
#     RUN go mod download:
    
#     Загружает все зависимости, указанные в go.mod, что позволяет избежать повторного скачивания их при последующих изменениях кода.
#     COPY . .:
    
#     Копирует весь исходный код приложения в рабочую директорию контейнера.
#     RUN CGO_ENABLED=0 GOOS=linux go build -o server .:
    
#     Компилирует приложение Go с настройками:
#     CGO_ENABLED=0: Отключает использование CGo, чтобы получить чисто статически скомпилированный бинарный файл.
#     GOOS=linux: Указывает целевую операционную систему как Linux.
#     -o server: Устанавливает имя скомпилированного исполняемого файла как server.


# 2. Стадия выполнения (Runtime Stage)
# Стадия выполнения используется для запуска уже скомпилированного приложения в более лёгком и оптимизированном контейнере, часто на основе минималистичного образа, например, alpine.

# Детали:
#     FROM alpine:latest:
    
#     Использует последнюю версию образа alpine в качестве базового для выполнения приложения, что минимизирует размер финального образа.
#     WORKDIR /root/:
    
#     Устанавливает рабочую директорию для всех последующих команд в /root.
#     COPY --from=builder /app/server .:
    
#     Копирует скомпилированный исполняемый файл server из контейнера builder в текущую рабочую директорию контейнера выполнения.
#     COPY .env .:
    
#     Копирует файл .env с переменными окружения в текущую рабочую директорию контейнера.
#     EXPOSE 8080:
    
#     Указывает, что контейнер будет прослушивать соединения на порту 8080. Это не открывает порт, но служит для документации и может быть использовано инструментами оркестрации.
#     CMD ["./server"]:
    
#     Определяет команду для запуска приложения. Здесь она запускает исполняемый файл server.


# Детали конфигурации
# version: '3.9':

# Указывает версию формата файла Compose, которую вы используете. Версия 3.9 обеспечивает совместимость с последними версиями Docker и предоставляет доступ ко всем новым возможностям.
# services:

# Секции services определяет один или несколько сервисов, которые вы хотите запустить. Каждый сервис может представлять собой контейнер или группу контейнеров, работающих вместе.
# Сервис web
# web:

# Это имя сервиса, которое используется для идентификации внутри Docker Compose. Оно может быть произвольным, но обычно отражает функцию контейнера (например, web, db).
# build: .:

# Указывает, что для сборки контейнера используется текущая директория (.) как контекст сборки. Это означает, что Docker Compose использует Dockerfile в текущей директории для создания образа контейнера.
# ports::

# Эта секция описывает перенаправление портов из контейнера на хост-машину.
# "8080:8080":
# Первый номер 8080 указывает порт на хосте, который будет открыт для доступа.
# Второй номер 8080 указывает порт внутри контейнера, на котором приложение слушает запросы. Это соответствует порту, указанному в Dockerfile с помощью EXPOSE.
# env_file::

# Секция env_file указывает на файл с переменными окружения, которые будут использоваться в контейнере.
# .env:
# Docker Compose будет читать переменные из указанного файла .env и передавать их в контейнер как переменные окружения.
