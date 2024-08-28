ARG ERIC_ENM_SLES_BASE_IMAGE_NAME=eric-enm-sles-base
ARG ERIC_ENM_SLES_BASE_IMAGE_REPO=armdocker.rnd.ericsson.se/proj-enm
ARG ERIC_ENM_SLES_BASE_IMAGE_TAG=1.64.0-33

FROM ${ERIC_ENM_SLES_BASE_IMAGE_REPO}/${ERIC_ENM_SLES_BASE_IMAGE_NAME}:${ERIC_ENM_SLES_BASE_IMAGE_TAG}

ARG BUILD_DATE=unspecified
ARG IMAGE_BUILD_VERSION=unspecified
ARG GIT_COMMIT=unspecified
ARG ISO_VERSION=unspecified
ARG RSTATE=unspecified

LABEL \
com.ericsson.product-number="CXC Placeholder" \
com.ericsson.product-revision=$RSTATE \
enm_iso_version=$ISO_VERSION \
org.label-schema.name="ENM data migration container" \
org.label-schema.build-date=$BUILD_DATE \
org.label-schema.vcs-ref=$GIT_COMMIT \
org.label-schema.vendor="Ericsson" \
org.label-schema.version=$IMAGE_BUILD_VERSION \
org.label-schema.schema-version="1.0.0-rc1"

ENV PATH="/opt/ericsson/eric-enm-data-migration/aliases:${PATH}" \
      CLOUD_NATIVE_DEPLOYMENT=true \
      PYTHONPATH="/opt/ericsson/data_migration/.env/lib/python3.11/site-packages/enmutils/lib"

RUN /usr/sbin/groupadd "wheel" > /dev/null 2>&1

COPY image_content            /opt/ericsson/eric-enm-data-migration

RUN chmod -R 755 /opt/ericsson/eric-enm-data-migration/aliases/ && \
    echo "source enm_version" >> ~/.bashrc

RUN zypper remove -y python3 python3-base > /dev/null 2>&1 | true && \
    zypper -n install python311 python311-pip && \
    ln -s /usr/bin/python3.11 /usr/bin/python3 && \
    ln -s /usr/bin/python3.11 /usr/bin/python

RUN zypper install -y libxslt1
RUN zypper install -y ERICdatamigration2_CXP9042224
RUN pip install virtualenv && \
    zypper install -y openssh && \
    zypper clean -a

RUN sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers

RUN echo "RPM Version : `rpm -qa | grep ERICdata`" >> ~/.version_info && \
    chmod 755 ~/.version_info

ENTRYPOINT ["rsyslogd", "-n"]
