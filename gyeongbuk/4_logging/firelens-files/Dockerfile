FROM amazon/aws-for-fluent-bit:latest

COPY extra.conf /fluent-bit/etc/extra.conf
COPY parsers.conf /fluent-bit/etc/parsers.conf
COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
