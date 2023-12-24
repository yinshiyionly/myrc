FROM debian:12.4

COPY ./docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

#ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/bin/bash"]
