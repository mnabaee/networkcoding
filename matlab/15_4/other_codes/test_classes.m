%% test_classes.m

close all;
clear all;
clc;

m_channel = channel;
m_sensor_deployment = sensor_deployment(m_channel);
%m_sensor_deployment.plot_this;


time_res = 1e-8;
carrier = carrier_signal(2580e6,0);
tc = 1/(2e6);
modulator = modulator_2500meg(carrier,tc,time_res);
phy = phy_module(modulator);
mac_address = rand(1,16) > .5;
mac = mac_module(mac_address,mac_address,phy);



time_at = 0;

for r=1:50
m_ack_req = 0;
m_dest_add = mac_address;
m_dest_pan_id = mac_address;
m_src_add = mac_address;
m_src_pan_id = mac_address;
m_seq_num = rand(1,8) > .5;
data_packet = packet_general;
data_packet.addToEnd(rand(1,8) > .5);
mac_data_packet = mac.create_mac_data_frame(m_ack_req,m_dest_pan_id,m_dest_add,m_src_pan_id,m_src_add,m_seq_num,data_packet);
phy_binary = phy.create_phy_packet(mac_data_packet).get_all;
signal{r} = mac.convert_mac_packet_to_signal(mac_data_packet,time_at);
time_at = signal{r}.get_end_time + mac.calculate_IFS_signal_time(mac_data_packet.getSize);
end
s = signal_continous_time(signal{1}.get_init_time,signal{end}.get_end_time,[signal{1}.get_init_time:time_res:signal{end}.get_end_time]*0);
for r=1:length(signal)
	s.set_as_part(signal{r});
end
%figure,signal.plot_this('r');
binary_dec_phy = modulator.demodulate_signal_to_phy_packet(s).get_all;
mac_pay_loads = mac.decode_binary_string_to_mac_pay_loads(binary_dec_phy);

%sum(abs(phy_binary-binary_dec_phy));

