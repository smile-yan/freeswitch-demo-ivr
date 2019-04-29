package cn.smileyan.tts;

import com.alibaba.nls.client.protocol.NlsClient;
import com.alibaba.nls.client.protocol.OutputFormatEnum;
import com.alibaba.nls.client.protocol.SampleRateEnum;
import com.alibaba.nls.client.protocol.tts.SpeechSynthesizer;
import com.alibaba.nls.client.protocol.tts.SpeechSynthesizerListener;
import com.alibaba.nls.client.protocol.tts.SpeechSynthesizerResponse;
import com.aliyuncs.exceptions.ClientException;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Scanner;
/**
 * SpeechSynthesizerDemo class
 *
 * 语音合成（TTS）Demo
 */
public class SpeechSynthesizerDemo {
    private String appKey;
    private String accessToken;
    private String text;
    private String filename;

    NlsClient client;
    public String getText() {
		return text;
	}
	public void setText(String text) {
		this.text = text;
	}


	public String getFilename() {
		return filename;
	}
	public void setFilename(String filename) {
		this.filename = filename;
	}
	public SpeechSynthesizerDemo(String appKey, String token) {
        this.appKey = appKey;
        this.accessToken = token;
        // Step0 创建NlsClient实例,应用全局创建一个即可,默认服务地址为阿里云线上服务地址
        client = new NlsClient(accessToken);
    }
    private static SpeechSynthesizerListener getSynthesizerListener(final String username ) {
        SpeechSynthesizerListener listener = null;
        try {
            listener = new SpeechSynthesizerListener() {
            	final String file = username + ".wav";
                File f = new File(file);
                FileOutputStream fout = new FileOutputStream(f);
                // 语音合成结束
                @Override
                public void onComplete(SpeechSynthesizerResponse response) {
                    // 事件名称 SynthesisCompleted
                    System.out.println("name: " + response.getName() +
                            // 状态码 20000000 表示识别成功
                            ", status: " + response.getStatus() +
                            // 语音合成文件路径
                            ", output file :"+ f.getAbsolutePath()
                    );
                }
                // 语音合成的语音二进制数据
                @Override
                public void onMessage(ByteBuffer message) {
                    try {
                        byte[] bytesArray = new byte[message.remaining()];
                        message.get(bytesArray, 0, bytesArray.length);
                        System.out.println("write array:" + bytesArray.length);
                        fout.write(bytesArray);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            };
        } catch (Exception e) {
            e.printStackTrace();
        }
        return listener;
    }
    public void process() {
        SpeechSynthesizer synthesizer = null;
        try {
            // Step1 创建实例,建立连接
            synthesizer = new SpeechSynthesizer(client, getSynthesizerListener(this.filename));
            synthesizer.setAppKey(appKey);
            // 设置返回音频的编码格式
            synthesizer.setFormat(OutputFormatEnum.WAV);
            // 设置返回音频的采样率
            synthesizer.setSampleRate(SampleRateEnum.SAMPLE_RATE_16K);
            // 设置用于语音合成的文本
            synthesizer.setText(""+this.text);
            // Step2 此方法将以上参数设置序列化为json发送给服务端,并等待服务端确认
            synthesizer.start();
            // Step3 等待语音合成结束
            synthesizer.waitForComplete();
        } catch (Exception e) {
            System.err.println(e.getMessage());
        } finally {
            // Step4 关闭连接
            if (null != synthesizer) {
                synthesizer.close();
            }
        }
    }
    public void shutdown() {
        client.shutdown();
    }
    public static void main(String[] args) throws ClientException {
    	// 1.默认自带三个参数
    	Scanner scanner = new Scanner(System.in);
    	int times=1;
        if (args.length != 2) {
        	System.err.println("请输出参数<appKey>、<token>与运行次数");
        	args = new String[4];
        	args[0] = scanner.next();
        	args[1] = scanner.next();
        	times = scanner.nextInt();
        }
        
        String appKey = args[0];
        String token = args[1];
    	SpeechSynthesizerDemo demo = new SpeechSynthesizerDemo(appKey, token);
        while(times-->0) {
        	System.out.print("请输入您要转换生成的文件名（不带扩展名），与要转换的文字（文字间不含空格）：");
        	String filename = scanner.next();
        	String text = scanner.next();
        	demo.setFilename(filename);
        	demo.setText(text);
        	demo.process();
        	System.out.println();
        }
        
        demo.shutdown();
        scanner.close();
        System.out.println("感谢使用，已经运行完毕！");
    }
}