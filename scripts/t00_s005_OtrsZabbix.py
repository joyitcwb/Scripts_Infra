#!/usr/bin/env python
# -*- coding: utf-8 -*-
###############################################################
# Autor: Janssen dos Reis Lima - janssenreislima@gmail.com    #
# Objetivo: Abrir e fechar registros no no OTRS via API       #
#           a partir de um problema identificado pelo Zabbix  #
# Versao: 1.0                                                 #
###############################################################

from otrs.ticket.template import GenericTicketConnectorSOAP
from otrs.client import GenericInterfaceClient
from otrs.ticket.objects import Ticket, Article, DynamicField, Attachment
import sys, os


server_uri = 'http://suporte.joyit.com.br'
webservice_name = 'IntegraZabbix'
client = GenericInterfaceClient(server_uri, tc=GenericTicketConnectorSOAP(webservice_name))

client.tc.SessionCreate(customer_user_login=sys.argv[7], password='eS@126585')

fechar_ticket = Ticket(State='Incidente Resolvido')

assunto_artigo_fechado = "O Sistema de Monitoramento detectou que o incidente foi solucionado atraves do evento " + sys.argv[4]
estado_trigger = sys.argv[6]
artigo_fechar = Article(Subject=assunto_artigo_fechado, Body=assunto_artigo_fechado, Charset='UTF8', MimeType='text/plain')

def abrirTicket():
    corpo = sys.argv[3] + " " + sys.argv[4]
    evento = sys.argv[4]

    t = Ticket(State='new', PriorityID=sys.argv[8], Queue=sys.argv[9], Title=sys.argv[1], Charset='UTF8', CustomerUser=sys.argv[7], Type=sys.argv[11], Service='Monitoramento', SLA=sys.argv[10])

    a = Article(Subject=sys.argv[1], Body=corpo, Charset='UTF8', MimeType='text/plain')

    df1 = DynamicField(Name='ZabbixIdTrigger', Value=sys.argv[5])
    df2 = DynamicField(Name='ZabbixStateTrigger', Value=sys.argv[6])
    df3 = DynamicField(Name='ZabbixEvento', Value=sys.argv[4])

    ticket_id, numero_ticket = client.tc.TicketCreate(t, a, [df1, df2, df3])

    comando = "python /usr/lib/zabbix/externalscripts/ack-zabbix.py " + str(evento) + " " + str(numero_ticket)
    os.system(comando)

def fecharTicket():
    df_searchId = DynamicField(Name='ZabbixIdTrigger', Value=sys.argv[5], Operator='Like')
    df_searchState = DynamicField(Name='ZabbixStateTrigger', Value=sys.argv[6], Operator='Like')
    busca_df=client.tc.TicketSearch(OwnerIDs=8, Queues=sys.argv[9], dynamic_fields=[df_searchId])
    client.tc.TicketUpdate(ticket_id=busca_df[0], ticket=fechar_ticket, article=artigo_fechar)

if estado_trigger == "OK":
    fecharTicket()
else:
    abrirTicket()
